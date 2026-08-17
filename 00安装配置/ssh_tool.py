#!/usr/bin/env python3
"""Execute commands and upload files to the K3s VM over verified SSH."""

import json
import os
import shlex
import sys
from pathlib import Path, PurePosixPath

import paramiko


sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")

DEFAULT_HOST = "192.168.253.128"
DEFAULT_USER = "lgy"
DEFAULT_KEY_FILE = Path.home() / ".ssh" / "id_rsa"
DEFAULT_KUBECONFIG = "/home/lgy/.kube/config"
CONFIG_FILE = Path.home() / ".ssh_tools_config.json"
ALLOWED_CONFIG_KEYS = {"host", "user", "port", "key_file", "kubeconfig"}


def load_config():
    config = {
        "host": DEFAULT_HOST,
        "user": DEFAULT_USER,
        "port": 22,
        "key_file": str(DEFAULT_KEY_FILE),
        "kubeconfig": DEFAULT_KUBECONFIG,
    }

    if CONFIG_FILE.exists():
        with CONFIG_FILE.open("r", encoding="utf-8") as handle:
            saved = json.load(handle)
        config.update({key: saved[key] for key in ALLOWED_CONFIG_KEYS if key in saved})

    env_overrides = {
        "host": os.environ.get("SSH_TOOL_HOST"),
        "user": os.environ.get("SSH_TOOL_USER"),
        "key_file": os.environ.get("SSH_TOOL_KEY_FILE"),
        "kubeconfig": os.environ.get("SSH_TOOL_KUBECONFIG"),
    }
    config.update({key: value for key, value in env_overrides.items() if value})
    if os.environ.get("SSH_TOOL_PORT"):
        config["port"] = int(os.environ["SSH_TOOL_PORT"])
    return config


def save_config(config):
    safe_config = {key: config[key] for key in ALLOWED_CONFIG_KEYS if key in config}
    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with CONFIG_FILE.open("w", encoding="utf-8") as handle:
        json.dump(safe_config, handle, indent=2)


def connect(config):
    key_file = Path(config["key_file"]).expanduser()
    password = os.environ.get("SSH_TOOL_PASSWORD")
    if not key_file.is_file() and not password:
        raise FileNotFoundError(f"SSH private key not found: {key_file}")

    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.RejectPolicy())
    client.connect(
        config["host"],
        port=int(config["port"]),
        username=config["user"],
        password=password,
        key_filename=str(key_file) if key_file.is_file() else None,
        allow_agent=True,
        look_for_keys=True,
        timeout=30,
        auth_timeout=30,
        banner_timeout=30,
    )
    return client


def redact(text, secrets):
    result = text
    for secret in secrets:
        if secret:
            result = result.replace(secret, "***")
    return result


def exec_command(client, command, config, sudo=False):
    kubeconfig = shlex.quote(config["kubeconfig"])
    remote_command = f"export KUBECONFIG={kubeconfig}; {command}"
    sudo_password = os.environ.get("SSH_TOOL_SUDO_PASSWORD")
    secrets = [sudo_password]

    if sudo:
        quoted = shlex.quote(remote_command)
        if sudo_password:
            remote_command = f"sudo -S -p '' -- sh -c {quoted}"
        else:
            remote_command = f"sudo -n -- sh -c {quoted}"

    stdin, stdout, stderr = client.exec_command(remote_command, get_pty=False)
    if sudo and sudo_password:
        stdin.write(sudo_password + "\n")
        stdin.flush()
    stdin.close()

    stdout_text = stdout.read().decode("utf-8", errors="replace")
    stderr_text = stderr.read().decode("utf-8", errors="replace")
    exit_status = stdout.channel.recv_exit_status()
    return (
        redact(stdout_text, secrets),
        redact(stderr_text, secrets),
        exit_status,
    )


def apply_overrides(config, host=None, user=None):
    if host:
        config["host"] = host
    if user:
        config["user"] = user
    return config


def cmd_upload(local_path, remote_path, host=None, user=None):
    config = apply_overrides(load_config(), host, user)
    local_file = Path(local_path)
    if not local_file.is_file():
        print(f"Local file not found: {local_path}", file=sys.stderr)
        return 1

    client = None
    sftp = None
    try:
        client = connect(config)
        remote_dir = str(PurePosixPath(remote_path).parent)
        _, stderr_text, exit_status = exec_command(
            client, f"mkdir -p -- {shlex.quote(remote_dir)}", config
        )
        if exit_status != 0:
            if stderr_text:
                print(stderr_text, file=sys.stderr, end="")
            return exit_status

        sftp = client.open_sftp()
        sftp.put(str(local_file), remote_path)
        print(f"Uploaded: {local_file} -> {config['host']}:{remote_path}")
        return 0
    except Exception as exc:
        print(f"SSH upload failed: {exc}", file=sys.stderr)
        return 1
    finally:
        if sftp:
            sftp.close()
        if client:
            client.close()


def cmd_ssh(command, host=None, user=None, sudo=False):
    config = apply_overrides(load_config(), host, user)
    client = None
    try:
        client = connect(config)
        stdout_text, stderr_text, exit_status = exec_command(
            client, command, config, sudo=sudo
        )
        if stdout_text:
            print(stdout_text, end="" if stdout_text.endswith("\n") else "\n")
        if stderr_text:
            print(stderr_text, file=sys.stderr, end="" if stderr_text.endswith("\n") else "\n")
        return exit_status
    except Exception as exc:
        print(f"SSH command failed: {exc}", file=sys.stderr)
        return 1
    finally:
        if client:
            client.close()


def cmd_exec_file(file_path, host=None, user=None, sudo=False):
    config = apply_overrides(load_config(), host, user)
    try:
        with open(file_path, "r", encoding="utf-8") as handle:
            commands = [line.strip() for line in handle if line.strip() and not line.lstrip().startswith("#")]
    except OSError as exc:
        print(f"Cannot read command file: {exc}", file=sys.stderr)
        return 1

    client = None
    try:
        client = connect(config)
        for index, command in enumerate(commands, start=1):
            print(f"[{index}/{len(commands)}] executing")
            stdout_text, stderr_text, exit_status = exec_command(
                client, command, config, sudo=sudo
            )
            if stdout_text:
                print(stdout_text, end="" if stdout_text.endswith("\n") else "\n")
            if stderr_text:
                print(stderr_text, file=sys.stderr, end="" if stderr_text.endswith("\n") else "\n")
            if exit_status != 0:
                print(f"Remote command failed with exit code {exit_status}", file=sys.stderr)
                return exit_status
        return 0
    except Exception as exc:
        print(f"SSH command file failed: {exc}", file=sys.stderr)
        return 1
    finally:
        if client:
            client.close()


def usage():
    print("Usage:")
    print("  ssh_tool.py cmd '<command>' [sudo]")
    print("  ssh_tool.py exec '<file_path>' [sudo]")
    print("  ssh_tool.py upload '<local_path>' '<remote_path>'")
    print("  ssh_tool.py config")


def main():
    if len(sys.argv) < 2:
        usage()
        return 1

    action = sys.argv[1]
    use_sudo = len(sys.argv) > 3 and sys.argv[3] == "sudo"

    if action == "cmd":
        command = sys.argv[2] if len(sys.argv) > 2 else input("Command: ")
        return cmd_ssh(command, sudo=use_sudo)
    if action == "exec":
        file_path = sys.argv[2] if len(sys.argv) > 2 else input("Command file: ")
        return cmd_exec_file(file_path, sudo=use_sudo)
    if action == "upload":
        if len(sys.argv) < 4:
            usage()
            return 1
        return cmd_upload(sys.argv[2], sys.argv[3])
    if action == "config":
        config = load_config()
        print(json.dumps(config, indent=2))
        return 0

    usage()
    return 1


if __name__ == "__main__":
    sys.exit(main())
