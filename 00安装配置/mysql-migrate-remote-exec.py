#!/usr/bin/env python3
"""Run the MySQL migration script while passing the source password through SSH stdin."""

import os
import shlex
import sys

import ssh_tool


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in {"preflight", "migrate", "verify", "verify-exact-rows", "background-migrate"}:
        print("Usage: mysql-migrate-remote-exec.py [preflight|migrate|verify|background-migrate]", file=sys.stderr)
        return 2

    password = os.environ.get("SOURCE_MYSQL_PASSWORD")
    if not password:
        print("SOURCE_MYSQL_PASSWORD is required", file=sys.stderr)
        return 2

    client = None
    try:
        config = ssh_tool.load_config()
        client = ssh_tool.connect(config)
        action = sys.argv[1]
        if action == "background-migrate":
            action = "migrate"
            command_suffix = (
                f"nohup /tmp/mysql-migrate-readonly-source.sh {action} "
                ">/tmp/mysql-migrate.log 2>&1 </dev/null & echo $!"
            )
        else:
            command_suffix = f"exec /tmp/mysql-migrate-readonly-source.sh {action}"
        command = (
            f"export KUBECONFIG={shlex.quote(config['kubeconfig'])}; "
            "read -r SOURCE_MYSQL_PASSWORD; "
            "export SOURCE_MYSQL_PASSWORD; "
            + command_suffix
        )
        stdin, stdout, stderr = client.exec_command(command, get_pty=False)
        stdin.write(password + "\n")
        stdin.flush()
        stdin.close()
        output = stdout.read().decode("utf-8", errors="replace")
        error = stderr.read().decode("utf-8", errors="replace")
        status = stdout.channel.recv_exit_status()
        if output:
            print(output, end="" if output.endswith("\n") else "\n")
        if error:
            print(error, file=sys.stderr, end="" if error.endswith("\n") else "\n")
        return status
    finally:
        if client:
            client.close()


if __name__ == "__main__":
    sys.exit(main())
