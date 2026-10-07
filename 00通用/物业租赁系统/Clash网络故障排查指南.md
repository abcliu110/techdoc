# Clash 网络故障排查指南

> 供 AI 和运维人员排查 Windows 下 Clash Verge Rev/Mihomo 的“节点全部超时、换网络后失效、不开 Clash 可正常上网”等问题。

## 一、AI 断网时的处理方式

开启 Clash 后如果 AI 无法联网，不要继续在线排查，也不要立即修改配置。改用同目录下的本地脚本离线取证：

```text
Clash故障现场采集.ps1
```

按以下顺序操作：

```powershell
# 1. 切换到中兴路由器，保持 Clash 关闭，采集基线
& "D:\mywork\techdoc\00通用\物业租赁系统\Clash故障现场采集.ps1" -Phase baseline

# 2. 开启 Clash 并复现；即使 AI 已断网，仍可在本机终端采集
& "D:\mywork\techdoc\00通用\物业租赁系统\Clash故障现场采集.ps1" -Phase fault

# 3. 关闭 Clash 恢复联网，可选采集恢复状态
& "D:\mywork\techdoc\00通用\物业租赁系统\Clash故障现场采集.ps1" -Phase recovery
```

如知道节点域名和端口，可附加：

```powershell
-NodeHost "节点域名" -NodePort 443
```

脚本会输出证据目录。恢复联网后，把目录路径和复现起止时间告诉 AI，由 AI 读取本地文件分析。脚本不会上传数据，也不会复制订阅和节点认证配置。

## 二、取证原则

1. 先记录时间和环境，再读取日志；以日志行时间为准，不能只看文件名。
2. 正常网络与故障网络必须使用同一电脑、配置、节点、协议和 HTTPS 测试地址。
3. 每项至少测试 3 次；条件允许时执行“正常 → 故障 → 恢复正常”的回转验证。
4. 每次只改变一个变量；初次复现前不得修改 Clash 或路由器配置。
5. “未观察到”不等于“已排除”；只有可重复、可逆的单变量结果才能确认因果。
6. 不得输出节点密码、UUID、订阅地址等敏感信息。

## 三、日志位置与选择

数据目录：

```text
%APPDATA%\io.github.clash-verge-rev.clash-verge-rev
```

本机对应：

```text
C:\Users\16555\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev
```

| 运行状态 | 主要日志 |
|----------|----------|
| Service 模式 | `logs\service\service_latest.log` |
| Sidecar 模式 | `logs\sidecar\sidecar_latest.log` |
| 启动、配置应用、IPC问题 | `logs\latest.log` |
| 历史会话 | 对应目录下带日期的 `.log` 文件 |

先从客户端日志中的 `Starting core in service mode/sidecar mode` 判断实际模式。`latest` 文件可能是带日期日志的别名；统计时只选择一套来源，不能同时统计别名和原文件。

```powershell
$logRoot = Join-Path $env:APPDATA 'io.github.clash-verge-rev.clash-verge-rev\logs'
Get-Content "$logRoot\service\service_latest.log" -Tail 200
```

便携版或自定义 `-d` 启动时，以进程命令行指定的数据目录为准。

## 四、严格 A/B 对照

切换网络后先保持 Clash 关闭，记录：

```text
网络：光猫直连 / 中兴路由器
开始与结束时间：精确到秒
Clash Verge Rev及Mihomo版本：
节点匿名编号、协议和端口：
TUN：开/关
系统代理：开/关
测试URL：
每项三次结果：
```

两种网络必须执行相同项目：

| 项目 | 光猫直连 | 中兴路由器 |
|------|----------|------------|
| 物理接口、IPv4/IPv6地址 | 记录 | 记录 |
| 默认网关、DNS | 记录 | 记录 |
| 节点解析出的真实 A/AAAA | 记录 | 记录 |
| 相同节点 IP/端口测试3次 | 记录 | 记录 |
| 相同代理 GET测试3次 | 记录 | 记录 |
| 同一时间窗口核心日志 | 保存 | 保存 |

若现象只在中兴环境稳定出现，恢复光猫后又稳定消失，才能将“中兴路径”列为高概率原因。

## 五、采集 Windows 网络状态

先找真实物理出口，避免把 Mihomo、VMware 等虚拟网卡误认为出口：

```powershell
Get-NetAdapter -Physical | Where-Object Status -eq 'Up'

Get-NetIPInterface -AddressFamily IPv4,IPv6 |
  Where-Object ConnectionState -eq Connected |
  Sort-Object AddressFamily,InterfaceMetric |
  Format-Table ifIndex,InterfaceAlias,AddressFamily,AutomaticMetric,InterfaceMetric,NlMtu

Get-NetIPConfiguration
Get-DnsClientServerAddress -AddressFamily IPv4,IPv6
```

确定物理接口编号后，只查看其 DNS：

```powershell
$ifIndex = 14 # 替换为实际物理接口编号
Get-DnsClientServerAddress -InterfaceIndex $ifIndex -AddressFamily IPv4,IPv6
```

查看默认路由和完整 TUN 路由：

```powershell
Get-NetRoute -PolicyStore ActiveStore |
  Where-Object DestinationPrefix -in '0.0.0.0/0','::/0'

Get-NetRoute -PolicyStore ActiveStore -IncludeAllCompartments |
  Sort-Object AddressFamily,DestinationPrefix,RouteMetric
```

最终出口以目标 IP 的选路为准：

```powershell
Find-NetRoute -RemoteIPAddress <真实节点IP>
```

注意检查 `/0`、IPv4 `/1` 拆分路由、IPv6路由、`198.18.*` fake-ip路由和节点服务器自身的绕行路由。

同时记录中兴管理页面的只读信息：

- AP/路由模式、WAN DHCP或PPPoE；
- WAN IPv4、网关、DNS和MTU；
- NAT、安全策略、ALG、家长控制；
- WAN IPv6、DHCPv6-PD前缀及长度、LAN RA。

确认双重 NAT 只代表拓扑，不等于它是全节点超时的根因。

## 六、基础节点连接测试

测试前必须退出 Clash 核心，关闭 TUN和系统代理，避免 fake-ip和DNS劫持污染结果：

```powershell
Get-Process '*mihomo*','*clash*' -ErrorAction SilentlyContinue
```

设置节点域名和端口，不要在报告中输出认证信息：

```powershell
$nodeHost = 'example.com' # 替换
$nodePort = 443           # 替换

$nodeIPv4 = Resolve-DnsName -Name $nodeHost -Type A -DnsOnly -NoHostsFile -QuickTimeout |
  Where-Object IPAddress |
  Select-Object -ExpandProperty IPAddress

Resolve-DnsName -Name $nodeHost -Type A -Server 223.5.5.5 -DnsOnly -NoHostsFile -QuickTimeout
Resolve-DnsName -Name $nodeHost -Type AAAA -DnsOnly -NoHostsFile -QuickTimeout

foreach ($ip in $nodeIPv4) {
  Find-NetRoute -RemoteIPAddress $ip
  Test-NetConnection -ComputerName $ip -Port $nodePort -InformationLevel Detailed |
    Format-List RemoteAddress,RemotePort,InterfaceAlias,SourceAddress,TcpTestSucceeded
}
```

解析结果若为 `198.18.*`，说明仍受 fake-ip影响，不能作为真实节点 IP。

`Test-NetConnection`只能验证一次 TCP建连，不能验证 TLS/SNI、认证或 UDP节点。Hysteria2、TUIC、QUIC等 UDP协议必须结合 Mihomo日志或协议级测试判断。

| 结果 | 只支持的判断 |
|------|--------------|
| 默认 DNS失败、指定 DNS成功 | 默认 DNS路径异常 |
| 相同真实 IP/端口直连成功、中兴失败 | 中兴路径上的该 TCP连接异常 |
| TCP成功、Clash仍失败 | 继续检查 Clash选路、协议和TUN |
| AAAA存在但基础网络没有 `::/0` | IPv6路径不完整的证据 |

## 七、分离核心、系统代理与 TUN

每一步固定相同节点、测试地址和次数，并从日志确认实际 outbound：

| 步骤 | TUN | 系统代理 | 测试刺激 |
|------|-----|----------|----------|
| A | 关 | 关 | 仅点击核心/UI节点测试 |
| B | 关 | 开 | 浏览器或显式代理 GET |
| A | 关 | 关 | 恢复基线 |
| C | 开 | 关 | 普通 GET，由 TUN接管 |
| A | 关 | 关 | 恢复基线 |
| D | 开 | 开 | 最后检查交互兼容性 |

短版 TUN配置只能用于核对字段，禁止整体覆盖订阅或运行时配置：

```yaml
tun:
  stack: mixed
  auto-route: true
  auto-detect-interface: true
```

若存在 `interface-name`，先确认它是否为当前出口；只能临时覆盖验证，不要直接删除订阅内容。

参考：[Mihomo TUN文档](https://wiki.metacubex.one/en/config/inbound/tun/)

## 八、按时间窗口读取日志

当前故障只分析当前 Service 日志：

```powershell
$root = Join-Path $env:APPDATA 'io.github.clash-verge-rev.clash-verge-rev\logs'
$files = @(Get-Item "$root\service\service_latest.log")
```

历史故障另选日期文件，不能与 `service_latest.log` 重复统计：

```powershell
# $files = @(Get-ChildItem "$root\service" -File -Filter 'service_*.log' |
#   Where-Object Name -ne 'service_latest.log')
```

过滤示例采用本地时间和半开区间 `[start, end)`，即不包含结束时刻：

```powershell
$start = [datetime]'2026-09-30 13:30:00'
$end   = [datetime]'2026-09-30 14:00:00'
$culture = [Globalization.CultureInfo]::InvariantCulture
$style = [Globalization.DateTimeStyles]::None

foreach ($file in $files) {
  foreach ($line in Get-Content $file.FullName) {
    if ($line -notmatch '^\[(?<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\]') {
      continue
    }
    $time = [datetime]::MinValue
    if (![datetime]::TryParseExact(
        $Matches['ts'], 'yyyy-MM-dd HH:mm:ss.fff', $culture, $style, [ref]$time)) {
      continue
    }
    if ($time -ge $start -and $time -lt $end -and
        $line -match '(?i)warn(?:ing)?|error|fatal|timeout|dns resolve|no ip address|unreachable|\[TUN\]') {
      "[$($file.Name)] $line"
    }
  }
}
```

原始日志必须保留；关键词过滤只用于阅读。没有命中只能写“该窗口和日志级别下未观察到”，不能写“已排除”。

## 九、错误关键词

| 关键词 | 含义 | 优先检查 |
|--------|------|----------|
| `dns resolve failed` | DNS解析失败 | Windows、路由器和Mihomo DNS分别验证 |
| `couldn't find ip` / `no ip address` | 没有可用地址 | 上游DNS、节点专用DNS、fake-ip |
| `i/o timeout` | TCP连接超时 | 真实节点IP、端口、路由、防火墙 |
| `context deadline exceeded` | 整体操作超时 | 节点连接、测速URL、重试链 |
| `unreachable network` | 缺少可用路由 | 地址族、默认路由、TUN路由 |
| `default interface changed` | Mihomo检测到出口变化 | ifIndex、路由和源地址 |
| `TLS handshake timeout` | TLS阶段超时 | 丢包、MTU、中间设备 |
| `failed to get the second response` | 健康检查失败 | 测速URL和请求方法 |

`DIRECT`只表示Mihomo记录的策略选择，不代表物理出口实际成功。

## 十、DNS诊断

需要分别验证：

- Windows默认DNS；
- 指定公共DNS；
- Mihomo普通域名DNS；
- Mihomo代理节点域名DNS。

字段含义：

- `default-nameserver`：解析DNS上游自身域名的启动解析器；
- `nameserver`：普通域名默认上游；
- `proxy-server-nameserver`：代理节点服务器域名解析器。

以下仅为**临时键级覆盖示例**，不得整体替换原 `dns:`，必须保留 `enhanced-mode`、`fake-ip-filter`、policy、fallback等原字段：

```yaml
dns:
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  proxy-server-nameserver:
    - 223.5.5.5
    - 119.29.29.29
```

不要直接编辑远程订阅或生成态 `clash-verge.yaml`；使用 Clash Verge Rev 的 Merge/Script 覆盖或临时本地配置，并在测试后还原。

```powershell
Resolve-DnsName www.baidu.com -Type A -DnsOnly -NoHostsFile -QuickTimeout
Resolve-DnsName www.baidu.com -Type A -Server 223.5.5.5 -DnsOnly -NoHostsFile -QuickTimeout
Clear-DnsClientCache
```

`Clear-DnsClientCache`只清Windows缓存，不清Mihomo、浏览器或路由器缓存；必要时分别重启对应组件。

参考：[Mihomo DNS文档](https://wiki.metacubex.one/en/config/dns/)

## 十一、IPv6诊断

基础网络关闭TUN后分别检查：

```powershell
Resolve-DnsName ipv6.test-ipv6.com -Type AAAA -DnsOnly -NoHostsFile -QuickTimeout
Get-NetRoute -DestinationPrefix '::/0' -ErrorAction SilentlyContinue
```

必须区分：

- 顶层 `ipv6`；
- `dns.ipv6`是否返回AAAA；
- 节点 `ip-version`偏好；
- TUN IPv6地址和路由；
- 光猫下发前缀 → 中兴获得PD → LAN发送RA → 终端获得地址和`::/0`。

关闭IPv6只能作为临时、可回滚的单变量实验。先确认节点不是IPv6-only；分别测试顶层和DNS开关，不要同时修改后直接归因。

## 十二、测速地址与真实代理请求

优先使用HTTPS，并至少交叉测试两个地址：

```text
https://www.gstatic.com/generate_204
https://cp.cloudflare.com/generate_204
```

单个测速URL失败不能等同于节点离线。`mixed-port/http-port`是共享入站，测试前必须把Global或目标策略组固定到指定节点，并从日志确认实际outbound。

```powershell
$proxy = 'http://127.0.0.1:7897' # 替换为实际共享端口
curl.exe --proxy $proxy --connect-timeout 8 --max-time 15 `
  --request GET --output NUL `
  --write-out "status=%{http_code} connect=%{time_connect}s total=%{time_total}s`n" `
  https://www.gstatic.com/generate_204
```

连续3次得到预期状态才可写“该节点到该URL在测试时可用”。这不能证明UDP、带宽或长期稳定性。

参考：[Mihomo入站端口文档](https://wiki.metacubex.one/en/config/inbound/port/)

## 十三、MTU诊断

仅在DNS正常、节点真实IP/端口可达，但出现TLS或大包超时时检查。先关闭TUN，对同一稳定响应ICMP的目标重复测试：

```powershell
ping.exe -4 -f -l 1472 223.5.5.5
ping.exe -4 -f -l 1464 223.5.5.5
ping.exe -4 -f -l 1452 223.5.5.5
ping.exe -4 -f -l 1400 223.5.5.5
```

IPv4路径MTU约等于最大成功payload加28。远端不回应ICMP时结果不确定；必须结合两种拓扑的同目标对照，以及临时降低WAN/TUN MTU后的可逆复测，不能单凭一次Ping确认。

## 十四、结论强度

- **已确认**：原始证据直接可见，或单变量结果可重复且还原后可逆。
- **支持假设/高概率**：故障组与对照组有稳定差异，但仍有替代解释。
- **未观察到**：当前时间窗口和日志级别下没有记录，不等于排除。
- **尚需验证**：缺少同条件对照、样本不足或测试路径未锁定。

输出模板：

```text
时间窗口与时区：
网络环境及版本：
测试条件、顺序、次数：
日志文件：

直接证据：
支持的假设：
未观察到：
替代解释/限制：
下一项单变量测试：
```

## 十五、本机案例边界

在 `2026-09-30 13:30:00–14:00:00` 半开窗口中，实际观察到：

- `dns resolve failed`：372条；
- `no ip address`：106条；
- IPv4 `i/o timeout`：20条；
- 在该窗口和日志级别下，未观察到 IPv6网络不可达、TUN接口切换、TLS握手或健康检查失败。

可以确认该时段存在大规模DNS失败；不能仅据此确认是中兴DNS转发、Mihomo DNS、上游DNS或其他环境因素。切换网络后必须重新采集，不能复用该结论。

## 十六、故障解决方案

> 必须先用前文方法确认故障类型。每次只应用一个可回滚变更，记录前后结果；禁止同时修改 DNS、IPv6、TUN和MTU。

### 16.1 方案矩阵

| 已获得的证据 | 高概率问题 | 首选方案 |
|--------------|------------|----------|
| 系统DNS成功，指定公共DNS失败 | 中兴限制或干扰外部53端口 | 用中兴DNS启动解析，普通查询改走DoH 443 |
| 系统和公共DNS成功，Mihomo仍报解析失败 | Mihomo DNS启动链或节点DNS异常 | 检查 `proxy-server-nameserver` 和fake-ip |
| 节点真实IP解析成功，但中兴环境端口失败 | 中兴安全过滤、ALG或协议/端口处理 | 关闭相关过滤，改用TCP 443或AP模式 |
| 出现IPv6 `unreachable network`且无`::/0` | IPv6-PD/RA或路由不完整 | 修复PD/RA，临时关闭IPv6对照 |
| 核心测速正常，仅TUN开启后失败 | TUN出口或路由错误 | 自动检测接口，检查固定接口和虚拟网卡 |
| HTTPS真实GET成功，界面测速超时 | 健康检查URL误报 | 改用HTTPS测速地址 |
| TCP建立后TLS/大包超时 | MTU/MSS或丢包 | 同路径测MTU，单变量调整WAN/TUN MTU |
| 中兴改AP后恢复 | 中兴路由/NAT/DNS功能异常 | 保持AP，或改为光猫桥接+中兴拨号 |

### 16.2 中兴限制外部DNS

确认条件：

```powershell
# 使用中兴下发的默认DNS成功
Resolve-DnsName www.baidu.com -Type A -DnsOnly -NoHostsFile -QuickTimeout

# 直接访问公共DNS失败
Resolve-DnsName www.baidu.com -Type A -Server 223.5.5.5 -DnsOnly -NoHostsFile -QuickTimeout
```

临时使用中兴DNS完成DoH和节点域名的启动解析，普通查询走HTTPS：

```yaml
dns:
  default-nameserver:
    - 192.168.10.1
  proxy-server-nameserver:
    - 192.168.10.1
  nameserver:
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
```

`192.168.10.1`必须替换为中兴实际LAN地址。以上只能作为Merge/Script键级覆盖，必须保留原有 `enhanced-mode`、`fake-ip-filter`、`nameserver-policy` 和 `fallback`，不得覆盖完整 `dns:` 或直接修改远程订阅。

验证：重新启动Mihomo，连续3次解析节点域名并执行HTTPS真实GET。若无改善，恢复原覆盖。

### 16.3 Mihomo DNS或fake-ip异常

适用条件：关闭Clash后系统DNS和公共DNS均成功，开启Clash后出现：

```text
dns resolve failed
couldn't find ip
no ip address
```

处理顺序：

1. 检查 `proxy-server-nameserver` 能否解析节点服务器域名；
2. 确认 `default-nameserver` 是纯IP，避免DoH启动解析循环；
3. 检查解析结果是否为 `198.18.*` fake-ip；
4. 补充必要的 `fake-ip-filter`；
5. 仅为对照时临时测试 `redir-host`，测试后恢复原模式；
6. 分别清理Windows、Mihomo和浏览器DNS缓存。

```powershell
Clear-DnsClientCache
```

不要用整段新DNS配置替换订阅配置。

### 16.4 IPv6路径不完整

确认线索：

```text
dial tcp [240e:...]: unreachable network
```

并且基础网络关闭TUN后没有IPv6默认路由：

```powershell
Get-NetRoute -DestinationPrefix '::/0' -ErrorAction SilentlyContinue
```

临时对照配置：

```yaml
ipv6: false

dns:
  ipv6: false
```

必须分别修改顶层 `ipv6` 和 `dns.ipv6` 做单变量测试，不能同时修改后归因。先确认节点不是IPv6-only。

长期方案：检查“光猫下发前缀 → 中兴WAN获得DHCPv6-PD → 中兴LAN发送RA → 终端获得公网IPv6和`::/0`”整条链路。修复后恢复IPv6，不必永久关闭。

### 16.5 TUN出口或路由错误

适用条件：TUN关闭时核心和系统代理正常，只有开启TUN后失败。

核对而非整段覆盖：

```yaml
tun:
  stack: mixed
  auto-route: true
  auto-detect-interface: true
```

处理步骤：

1. 查看日志中的 `default interface changed`；
2. 用 `Find-NetRoute -RemoteIPAddress <节点真实IP>`确认出口；
3. WLAN与有线网卡同时有默认路由时，临时只保留一个物理出口；
4. 检查 `interface-name` 是否绑定旧网卡；仅临时覆盖验证；
5. 检查VMware、Hyper-V等虚拟网卡的接口度量；
6. 必要时重新安装Clash服务和TUN驱动。

每次改变后回到相同基线，使用同一节点和URL连续测试3次。

### 16.6 中兴阻断节点端口或协议

确认要求：同一真实节点IP、端口和协议在光猫直连连续成功，在中兴环境连续失败；DNS和远端节点状态已排除。

处理顺序：

1. 临时关闭中兴家长控制、上网行为管理、黑白名单和安全过滤；
2. 临时关闭SIP、FTP、RTSP等ALG；
3. 降低防火墙安全等级并复测；
4. 升级中兴固件；
5. 节点优先尝试TCP/TLS 443；
6. UDP节点需做协议级测试，不能用 `Test-NetConnection` 判断；
7. 若路由模式失败而AP模式成功，保留AP模式或调整网络拓扑。

每项单独测试并及时恢复，不得直接关闭全部安全功能后长期使用。

### 16.7 测速地址误报

避免HTTP测速地址：

```text
http://1.1.1.1
http://cp.cloudflare.com/generate_204
```

改为至少两个HTTPS地址交叉测试：

```text
https://www.gstatic.com/generate_204
https://cp.cloudflare.com/generate_204
```

固定目标节点后，通过共享 `mixed-port/http-port`执行真实GET，并从日志确认实际outbound。连续3次返回预期状态，只能说明该节点到该URL在测试时可用。

### 16.8 MTU/MSS问题

仅在DNS和节点端口正常，但出现TLS握手或大包超时时处理。关闭TUN，对相同稳定目标重复测试：

```powershell
ping.exe -4 -f -l 1472 223.5.5.5
ping.exe -4 -f -l 1464 223.5.5.5
ping.exe -4 -f -l 1452 223.5.5.5
ping.exe -4 -f -l 1400 223.5.5.5
```

IPv4路径MTU约为最大成功payload加28。建议起点：

- DHCP/IPoE：WAN MTU 1500；
- PPPoE：WAN MTU 1492；
- 只有较小值稳定成功时，再临时测试1480或1460及MSS钳制。

ICMP不响应时结果无效。必须以“调整后故障稳定消失、恢复原值后故障重新出现”作为高概率证据。

### 16.9 双重NAT和最终兜底拓扑

确认双重NAT：中兴WAN获得光猫LAN私网地址，且光猫和中兴都执行路由/NAT。双重NAT本身通常不会使所有主动TCP连接超时，不能直接当作根因。

推荐二选一：

```text
方案A：光猫负责拨号、DHCP和NAT
光猫LAN → 中兴LAN/AP模式
中兴只提供Wi-Fi和交换
```

```text
方案B：光猫桥接
光猫 → 中兴WAN
中兴负责PPPoE、DHCP和唯一一次NAT
```

若运营商定制固件无法修复DNS、IPv6或NAT问题，AP模式是最简单可靠的绕过方案。

### 16.10 变更后的统一验证

每次只应用一个方案，然后执行：

1. 连续3次节点真实IP/端口测试；
2. 连续3次HTTPS真实GET；
3. 检查同一时间窗口Mihomo日志；
4. 恢复原值后复测，确认现象是否可逆；
5. 将结果写为“已确认、高概率、未观察到、尚需验证”之一。

开启Clash导致AI断网时，使用 `Clash故障现场采集.ps1 -Phase fault` 本地保存证据；关闭Clash恢复联网后，再把证据目录交给AI分析。

## 参考资料

- [Mihomo DNS配置](https://wiki.metacubex.one/en/config/dns/)
- [Mihomo TUN配置](https://wiki.metacubex.one/en/config/inbound/tun/)
- [Mihomo入站端口](https://wiki.metacubex.one/en/config/inbound/port/)
