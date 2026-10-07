[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('baseline', 'fault', 'recovery')]
    [string]$Phase,

    [string]$OutputRoot = 'D:\mywork\techdoc\00通用\物业租赁系统\clash-diagnostics',

    [ValidateRange(1, 1440)]
    [int]$SinceMinutes = 60,

    [string]$NodeHost,

    [ValidateRange(1, 65535)]
    [int]$NodePort = 443
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$capturedAt = Get-Date
$stamp = $capturedAt.ToString('yyyyMMdd-HHmmss-fff')
$sessionDir = Join-Path $OutputRoot "$stamp-$Phase"
New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null

function Save-Capture {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    $path = Join-Path $sessionDir $Name
    try {
        $content = & $Action *>&1 | Out-String -Width 4096
        Set-Content -LiteralPath $path -Value $content -Encoding utf8
    } catch {
        Set-Content -LiteralPath $path -Value ("CAPTURE ERROR: " + $_.Exception.Message) -Encoding utf8
    }
}

$metadata = [ordered]@{
    phase         = $Phase
    capturedAt    = $capturedAt.ToString('o')
    timeZone      = (Get-TimeZone).Id
    computer      = $env:COMPUTERNAME
    user          = $env:USERNAME
    sinceMinutes  = $SinceMinutes
    nodeHost      = if ($NodeHost) { $NodeHost } else { $null }
    nodePort      = if ($NodeHost) { $NodePort } else { $null }
    note          = 'Local-only evidence. No data is uploaded.'
}
$metadata | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $sessionDir '00-metadata.json') -Encoding utf8

Save-Capture '01-system.txt' {
    Get-Date -Format o
    Get-TimeZone
    Get-CimInstance Win32_OperatingSystem |
        Select-Object Caption, Version, BuildNumber, LastBootUpTime
}

Save-Capture '02-clash-processes.txt' {
    Get-CimInstance Win32_Process |
        Where-Object {
            $_.Name -match 'clash|mihomo|verge|flclash' -or
            $_.ExecutablePath -match 'clash|mihomo|verge|flclash'
        } |
        Select-Object ProcessId, ParentProcessId, Name, ExecutablePath
}

Save-Capture '03-adapters.txt' {
    '=== Physical adapters ==='
    Get-NetAdapter -Physical |
        Sort-Object ifIndex |
        Format-Table ifIndex, Name, InterfaceDescription, Status, LinkSpeed, MacAddress -AutoSize

    '=== Connected IP interfaces ==='
    Get-NetIPInterface -AddressFamily IPv4, IPv6 |
        Where-Object ConnectionState -eq Connected |
        Sort-Object AddressFamily, InterfaceMetric |
        Format-Table ifIndex, InterfaceAlias, AddressFamily, AutomaticMetric, InterfaceMetric, NlMtu -AutoSize

    '=== IP configuration ==='
    Get-NetIPConfiguration -All |
        Format-List InterfaceAlias, InterfaceDescription, InterfaceIndex, NetProfile, IPv4Address, IPv4DefaultGateway, IPv6Address, IPv6DefaultGateway, DNSServer
}

Save-Capture '04-default-routes.txt' {
    Get-NetRoute -PolicyStore ActiveStore |
        Where-Object DestinationPrefix -in '0.0.0.0/0', '::/0' |
        Sort-Object AddressFamily, RouteMetric |
        Format-Table ifIndex, InterfaceAlias, AddressFamily, DestinationPrefix, NextHop, RouteMetric, State -AutoSize
}

Save-Capture '05-all-routes.txt' {
    Get-NetRoute -PolicyStore ActiveStore -IncludeAllCompartments |
        Sort-Object AddressFamily, DestinationPrefix, RouteMetric |
        Format-Table ifIndex, InterfaceAlias, AddressFamily, DestinationPrefix, NextHop, RouteMetric, State -AutoSize
}

Save-Capture '06-dns-servers.txt' {
    Get-DnsClientServerAddress -AddressFamily IPv4, IPv6 |
        Sort-Object InterfaceIndex, AddressFamily |
        Format-Table InterfaceIndex, InterfaceAlias, AddressFamily, ServerAddresses -AutoSize
}

Save-Capture '07-proxy-settings.txt' {
    '=== WinINET/current user ==='
    Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' |
        Select-Object ProxyEnable, ProxyServer, AutoConfigURL

    '=== WinHTTP ==='
    netsh.exe winhttp show proxy

    '=== Listening proxy-like ports ==='
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object LocalPort -in 7890, 7891, 7892, 7897, 9090, 9097 |
        Sort-Object LocalPort |
        Format-Table LocalAddress, LocalPort, OwningProcess -AutoSize
}

Save-Capture '08-dns-tests.txt' {
    $domains = @('www.baidu.com', 'www.gstatic.com', 'cp.cloudflare.com')
    foreach ($domain in $domains) {
        "=== $domain / system DNS / A ==="
        try {
            Resolve-DnsName -Name $domain -Type A -DnsOnly -NoHostsFile -QuickTimeout -ErrorAction Stop |
                Select-Object Name, Type, IPAddress, NameHost
        } catch {
            "ERROR: $($_.Exception.Message)"
        }

        "=== $domain / 223.5.5.5 / A ==="
        try {
            Resolve-DnsName -Name $domain -Type A -Server 223.5.5.5 -DnsOnly -NoHostsFile -QuickTimeout -ErrorAction Stop |
                Select-Object Name, Type, IPAddress, NameHost
        } catch {
            "ERROR: $($_.Exception.Message)"
        }

        "=== $domain / system DNS / AAAA ==="
        try {
            Resolve-DnsName -Name $domain -Type AAAA -DnsOnly -NoHostsFile -QuickTimeout -ErrorAction Stop |
                Select-Object Name, Type, IPAddress, NameHost
        } catch {
            "ERROR: $($_.Exception.Message)"
        }
    }
}

Save-Capture '09-http-tests.txt' {
    foreach ($url in @('https://www.gstatic.com/generate_204', 'https://cp.cloudflare.com/generate_204')) {
        "=== $url ==="
        & curl.exe --silent --show-error --connect-timeout 5 --max-time 10 `
            --request GET --output NUL `
            --write-out "status=%{http_code} remote=%{remote_ip} connect=%{time_connect}s tls=%{time_appconnect}s total=%{time_total}s`n" `
            $url
        "curl_exit_code=$LASTEXITCODE"
    }
}

if ($NodeHost) {
    Save-Capture '10-node-tests.txt' {
        "NodeHost=$NodeHost"
        "NodePort=$NodePort"

        $resolvedIPv4 = @()
        foreach ($server in @($null, '223.5.5.5', '119.29.29.29')) {
            $label = if ($server) { $server } else { 'system DNS' }
            "=== Resolve A via $label ==="
            try {
                $params = @{
                    Name        = $NodeHost
                    Type        = 'A'
                    DnsOnly     = $true
                    NoHostsFile = $true
                    QuickTimeout = $true
                    ErrorAction = 'Stop'
                }
                if ($server) { $params.Server = $server }
                $answers = Resolve-DnsName @params
                $answers | Select-Object Name, Type, IPAddress, NameHost
                $resolvedIPv4 += $answers | Where-Object IPAddress | Select-Object -ExpandProperty IPAddress
            } catch {
                "ERROR: $($_.Exception.Message)"
            }
        }

        "=== Resolve AAAA via system DNS ==="
        try {
            Resolve-DnsName -Name $NodeHost -Type AAAA -DnsOnly -NoHostsFile -QuickTimeout -ErrorAction Stop |
                Select-Object Name, Type, IPAddress, NameHost
        } catch {
            "ERROR: $($_.Exception.Message)"
        }

        foreach ($ip in $resolvedIPv4 | Sort-Object -Unique | Select-Object -First 3) {
            "=== Route to $ip ==="
            try { Find-NetRoute -RemoteIPAddress $ip -ErrorAction Stop | Format-List * } catch { "ERROR: $($_.Exception.Message)" }

            "=== TCP $ip`:$NodePort ==="
            try {
                Test-NetConnection -ComputerName $ip -Port $NodePort -InformationLevel Detailed -WarningAction SilentlyContinue |
                    Format-List RemoteAddress, RemotePort, InterfaceAlias, SourceAddress, TcpTestSucceeded
            } catch {
                "ERROR: $($_.Exception.Message)"
            }
        }
    }
}

$clashHome = Join-Path $env:APPDATA 'io.github.clash-verge-rev.clash-verge-rev'
$runtimeConfig = Join-Path $clashHome 'clash-verge.yaml'
if (Test-Path -LiteralPath $runtimeConfig) {
    Save-Capture '11-safe-runtime-settings.txt' {
        Select-String -LiteralPath $runtimeConfig -Pattern @(
            '^(mode|ipv6|interface-name|mixed-port|port|socks-port|redir-port|tproxy-port|test-url):',
            '^\s{2}(enable|ipv6|enhanced-mode|fake-ip-range|stack|auto-route|auto-detect-interface|strict-route|mtu|dns-hijack|default-nameserver|nameserver|proxy-server-nameserver):'
        ) | ForEach-Object { $_.Line }
    }
}

$logSource = Join-Path $clashHome 'logs'
$logDestination = Join-Path $sessionDir 'logs'
$manifest = @()
if (Test-Path -LiteralPath $logSource) {
    $cutoff = (Get-Date).AddMinutes(-$SinceMinutes)
    foreach ($file in Get-ChildItem $logSource -Recurse -File -Filter '*.log' |
        Where-Object LastWriteTime -ge $cutoff) {
        $relativePath = $file.FullName.Substring($logSource.Length).TrimStart('\')
        $destinationPath = Join-Path $logDestination $relativePath
        $destinationParent = Split-Path $destinationPath -Parent
        New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
        try {
            Copy-Item -LiteralPath $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
            $copied = Get-Item -LiteralPath $destinationPath
            $manifest += [pscustomobject]@{
                source        = $file.FullName
                relativePath  = $relativePath
                length        = $copied.Length
                lastWriteTime = $file.LastWriteTime.ToString('o')
                sha256        = (Get-FileHash -LiteralPath $destinationPath -Algorithm SHA256).Hash
            }
        } catch {
            $manifest += [pscustomobject]@{
                source        = $file.FullName
                relativePath  = $relativePath
                error         = $_.Exception.Message
            }
        }
    }
}
ConvertTo-Json -InputObject @($manifest) -Depth 4 |
    Set-Content -LiteralPath (Join-Path $sessionDir '12-log-manifest.json') -Encoding utf8

$instructions = @"
Clash diagnostic evidence
=========================
Phase: $Phase
Captured: $($capturedAt.ToString('o'))
Directory: $sessionDir

Next steps:
1. Do not edit these evidence files.
2. For a fault capture, disable Clash to restore AI connectivity.
3. Give the AI this directory plus the exact reproduction start/end time.
4. Compare baseline, fault, and recovery captures under identical test conditions.

Security:
- Evidence remains local.
- Subscription files and full runtime configuration are not copied.
- Review logs before sharing them outside this computer.
"@
Set-Content -LiteralPath (Join-Path $sessionDir 'README.txt') -Value $instructions -Encoding utf8

Write-Host ''
Write-Host 'Clash evidence capture completed:' -ForegroundColor Green
Write-Host $sessionDir -ForegroundColor Cyan
