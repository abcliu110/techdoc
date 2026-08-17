[CmdletBinding()]
param(
    [string]$HostName = '192.168.253.128',
    [string]$UserName = 'lgy',
    [string]$PublicKeyPath = (Join-Path ([Environment]::GetFolderPath('UserProfile')) '.ssh\id_rsa.pub'),
    [SecureString]$Password
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sshTool = Join-Path $scriptDir 'ssh_tool.py'
$remoteKey = '/tmp/codex-id_rsa.pub'

if (-not (Test-Path -LiteralPath $sshTool -PathType Leaf)) {
    throw "SSH tool not found: $sshTool"
}
if (-not (Test-Path -LiteralPath $PublicKeyPath -PathType Leaf)) {
    throw "Public key not found: $PublicKeyPath"
}
if (-not $Password) {
    $Password = Read-Host 'SSH password' -AsSecureString
}

$passwordPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
try {
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPtr)
    $env:SSH_TOOL_HOST = $HostName
    $env:SSH_TOOL_USER = $UserName
    $env:SSH_TOOL_PASSWORD = $plainPassword

    & python $sshTool upload $PublicKeyPath $remoteKey
    if ($LASTEXITCODE -ne 0) { throw 'Public key upload failed' }

    & python $sshTool cmd "install -d -m 700 /home/$UserName/.ssh; touch /home/$UserName/.ssh/authorized_keys; chmod 600 /home/$UserName/.ssh/authorized_keys; grep -qxF -f $remoteKey /home/$UserName/.ssh/authorized_keys || cat $remoteKey >> /home/$UserName/.ssh/authorized_keys; rm -f $remoteKey"
    if ($LASTEXITCODE -ne 0) { throw 'Public key installation failed' }
}
finally {
    Remove-Item Env:SSH_TOOL_PASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:SSH_TOOL_HOST -ErrorAction SilentlyContinue
    Remove-Item Env:SSH_TOOL_USER -ErrorAction SilentlyContinue
    if ($passwordPtr -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPtr)
    }
    $plainPassword = $null
}

$env:SSH_TOOL_HOST = $HostName
$env:SSH_TOOL_USER = $UserName
try {
    & python $sshTool cmd 'id -un; hostname'
    if ($LASTEXITCODE -ne 0) { throw 'Key-only SSH verification failed' }
}
finally {
    Remove-Item Env:SSH_TOOL_HOST -ErrorAction SilentlyContinue
    Remove-Item Env:SSH_TOOL_USER -ErrorAction SilentlyContinue
}
