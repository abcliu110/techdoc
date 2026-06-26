# RKE2 涓?Rancher 杩戞湡鏁呴殰鎺掓煡璁板綍

## 1. 鑳屾櫙

- 鎺掓煡鐩爣锛歚192.168.1.119`
- 鐧诲綍鐢ㄦ埛锛歚jj`
- 涓绘満鍚嶏細`jjtestserver`
- 鎿嶄綔绯荤粺锛歎buntu 24.04.3 LTS
- Kubernetes 褰㈡€侊細鍗曡妭鐐?RKE2锛岃妭鐐瑰悓鏃舵壙鎷?`control-plane` 鍜?`etcd`
- Rancher 鍏ュ彛锛歚https://192.168.1.119`
- Rancher Ingress Host锛歚jjtestserver`
- 鎺掓煡鏃堕棿锛?026-05-19 15:17 CST 宸﹀彸

鏈鎺掓煡浣跨敤 SSH 鍙鏂瑰紡鏌ョ湅绯荤粺鐘舵€併€丷KE2 鏈嶅姟鐘舵€併€並ubernetes 鑺傜偣鐘舵€併€丳od 鐘舵€併€丷ancher 鏃ュ織鍜岀郴缁熼噸鍚褰曪紝鏈墽琛屽垹闄ゃ€侀噸鍚€佷慨鏀归厤缃瓑鎿嶄綔銆?
## 2. 褰撳墠缁撹

褰撳墠 RKE2 鍜?Kubernetes API 宸叉仮澶嶆甯革紝鏍稿績闂涓嶆槸 RKE2 鏈嶅姟鑷韩鍙嶅宕╂簝锛岃€屾槸涓绘満杩戞湡瀛樺湪棰戠箒鍏虫満鎴栭噸鍚紝瀵艰嚧鍗曡妭鐐归泦缇ゆ暣浣撲笉鍙敤锛屽苟鍦ㄦ仮澶嶅悗鐣欎笅澶ч噺鍘嗗彶寮傚父 Pod 璁板綍銆?
涓昏缁撹锛?
1. `rke2-server` 褰撳墠涓?`active (running)`銆?2. 鑺傜偣 `jjtestserver` 褰撳墠涓?`Ready`銆?3. Kubernetes API `/readyz` 妫€鏌ラ€氳繃銆?4. `rke2-server` 褰撳墠杩涚▼鑷?`2026-05-19 13:45:01 CST` 璧疯繍琛岋紝`NRestarts=0`銆?5. Rancher 绠＄悊闆嗙兢涓彧鏌ュ埌 `local` 闆嗙兢锛屾病鏈夋煡鍒板悕涓?`rke-2` 鐨?Rancher 闆嗙兢瀵硅薄銆?6. `cattle-system` 鍛藉悕绌洪棿娈嬬暀澶ч噺 `system-upgrade-controller` 鐨?`ContainerStatusUnknown` Pod銆?7. Rancher 鏃ュ織涓瓨鍦?Chart 浠撳簱鍚屾澶辫触锛屼富瑕佽〃鐜颁负 git fetch 缃戠粶涓柇銆?
## 3. 鍏抽敭璇佹嵁

### 3.1 RKE2 鏈嶅姟鐘舵€?
妫€鏌ョ粨鏋滄樉绀猴細

```text
rke2-server.service - Rancher Kubernetes Engine v2 (server)
Active: active (running) since Tue 2026-05-19 13:45:01 CST
Result=success
NRestarts=0
ExecMainStartTimestamp=Tue 2026-05-19 13:43:55 CST
ActiveEnterTimestamp=Tue 2026-05-19 13:45:01 CST
```

璇存槑锛?
- 褰撳墠鏈嶅姟鏄甯歌繍琛岀姸鎬併€?- 鏈疆杩愯鏈熼棿娌℃湁 systemd 灞傞潰鐨勮嚜鍔ㄩ噸鍚€?- 鏈€杩戜竴娆?RKE2 鍚姩涓庝富鏈哄惎鍔ㄦ椂闂撮珮搴︿竴鑷达紝鏇寸鍚堚€滀富鏈洪噸鍚悗 RKE2 闅忕郴缁熷惎鍔ㄢ€濈殑鐗瑰緛銆?
### 3.2 鑺傜偣涓?API 鍋ュ悍

鑺傜偣鐘舵€侊細

```text
jjtestserver   Ready   control-plane,etcd   105d   v1.34.3+rke2r1
```

API 鍋ュ悍妫€鏌ワ細

```text
[+]ping ok
[+]log ok
[+]etcd ok
[+]etcd-readiness ok
[+]informer-sync ok
readyz check passed
```

璇存槑锛?
- 褰撳墠鎺у埗骞抽潰鍜?etcd 鍙敤銆?- 鎺掓煡鏃舵病鏈夊彂鐜?API Server 褰撳墠涓嶅彲鐢ㄧ殑闂銆?
### 3.3 涓绘満鍏虫満涓庨噸鍚褰?
`last -x reboot shutdown` 鏄剧ず杩戞湡瀛樺湪澶氭鍏虫満鍜屽惎鍔細

```text
reboot   system boot  Tue May 19 13:43   still running
shutdown system down  Tue May 19 12:31 - 13:43  (01:11)
reboot   system boot  Mon May 18 14:44 - 12:31  (21:47)
shutdown system down  Mon May 18 14:39 - 14:44  (00:04)
reboot   system boot  Mon May 18 13:34 - 14:39  (01:05)
shutdown system down  Mon May 18 12:27 - 13:34  (01:06)
reboot   system boot  Mon May 18 10:47 - 12:27  (01:40)
shutdown system down  Mon May 18 10:18 - 10:47  (00:28)
```

璇存槑锛?
- 杩戞湡鏁呴殰鐨勭涓€浼樺厛绾х嚎绱㈡槸涓绘満绾у仠鏈恒€?- 鐢变簬璇ョ幆澧冩槸鍗曡妭鐐?RKE2锛屼富鏈哄仠鏈烘湡闂?Kubernetes銆丷ancher銆佷笟鍔℃湇鍔￠兘浼氭暣浣撲笉鍙敤銆?- 涓绘満鎭㈠鍚庯紝Pod 浼氶噸鏂版媺璧凤紝骞跺嚭鐜板ぇ閲忛噸鍚鏁般€佸巻鍙插紓甯哥姸鎬佹垨鏈煡鐘舵€佽褰曘€?
### 3.4 Pod 寮傚父缁熻

鎺掓煡鏃?Pod 鐘舵€佹憳瑕侊細

```text
total_pods=583
status Running 66
status Completed 30
status ContainerStatusUnknown 487
```

寮傚父 Pod 闆嗕腑鍦細

```text
cattle-system system-upgrade-controller-65d9b4b8b-* 0/1 ContainerStatusUnknown
```

璇存槑锛?
- 褰撳墠鏈€鏄剧溂鐨?Rancher UI 寮傚父鏄?`cattle-system` 涓嬪ぇ閲?`system-upgrade-controller` 鍘嗗彶寮傚父 Pod銆?- 褰撳墠 `system-upgrade-controller` 鏈韩鏈夎繍琛屽疄渚嬶紝鏃ュ織鏄剧ず鍏跺凡缁忓畬鎴?leader election 骞跺惎鍔ㄦ帶鍒跺櫒銆?- 杩欎簺 `ContainerStatusUnknown` 鏇村儚涓绘満鍋滄満鎴栧鍣ㄨ繍琛屾椂涓柇鍚庢畫鐣欑殑 Pod 鐘舵€侊紝鑰屼笉鏄綋鍓嶄粛鍦ㄦ寔缁け璐ョ殑涓氬姟 Pod銆?
### 3.5 Rancher Chart 浠撳簱鍚屾澶辫触

Rancher 鏃ュ織涓瓨鍦ㄤ互涓嬮敊璇細

```text
error syncing 'rancher-rke2-charts': handler helm-clusterrepo-ensure: ensure failure
git fetch origin ... error: RPC failed
curl 56 OpenSSL SSL_read ... unexpected eof while reading
fatal: early EOF
fatal: fetch-pack: invalid index-pack output
```

浠ュ強锛?
```text
error syncing 'rancher-partner-charts': handler helm-clusterrepo-ensure: ensure failure
curl 92 HTTP/2 stream ... INTERNAL_ERROR
fetch-pack: unexpected disconnect while reading sideband packet
```

璇存槑锛?
- 杩欑被閿欒涓昏褰卞搷 Rancher Apps/Charts 浠撳簱鍒锋柊銆?- 瀵瑰凡缁忚繍琛岀殑涓氬姟 Pod 涓嶄竴瀹氭湁鐩存帴褰卞搷銆?- 鏍瑰洜閫氬父涓庤闂閮?Chart/Git 浠撳簱鐨勭綉缁滅ǔ瀹氭€с€佷唬鐞嗐€丏NS銆乀LS 涓柇鎴栦笂娓镐粨搴撹繛鎺ヨ川閲忔湁鍏炽€?
## 4. 鏍瑰洜鍒ゆ柇

### 4.1 楂樼疆淇＄粨璁?
杩戞湡鏈€涓昏鐨勯棶棰樻槸涓绘満 `jjtestserver` 鍙戠敓杩囧娆″叧鏈烘垨閲嶅惎锛屽崟鑺傜偣 RKE2 闅忎富鏈哄仠鏈鸿€屾暣浣撲笉鍙敤銆?
鍒ゆ柇渚濇嵁锛?
- `last -x` 鏈夋槑纭?shutdown/reboot 璁板綍銆?- `rke2-server` 褰撳墠鍚姩鏃堕棿涓庣郴缁熷惎鍔ㄦ椂闂存帴杩戙€?- `rke2-server` 褰撳墠 `NRestarts=0`锛屾病鏈夎瘉鎹樉绀烘湰杞繍琛屼腑鐢?systemd 鑷姩鍙嶅鎷夎捣銆?- 澶ч噺 Pod 鍦ㄥ悓涓€鏃堕棿绐楀彛鍑虹幇閲嶅惎鎴?`ContainerStatusUnknown`锛岀鍚堜富鏈烘垨瀹瑰櫒杩愯鏃朵腑鏂悗鐨勮〃鐜般€?
### 4.2 涓疆淇＄粨璁?
`cattle-system` 涓ぇ閲?`system-upgrade-controller` 鐨?`ContainerStatusUnknown` 鏄巻鍙叉畫鐣欐垨閲嶅惎杩囩▼涓殑寮傚父鐘舵€佺Н绱€?
鍒ゆ柇渚濇嵁锛?
- 褰撳墠 `system-upgrade-controller` 鏈夎繍琛屽疄渚嬨€?- 寮傚父 Pod 鍧囦负鍚屼竴 Deployment/ReplicaSet 鍚嶇О鍓嶇紑銆?- 寮傚父鏁伴噺闈炲父澶э紝涓旂姸鎬侀泦涓负 `ContainerStatusUnknown`锛屾洿鍍忚妭鐐?瀹瑰櫒杩愯鏃跺け鑱斿悗鐨勭姸鎬侀仐鐣欍€?
### 4.3 鐙珛闂

Rancher Chart 浠撳簱鍚屾澶辫触鏄彟涓€涓渶瑕佽窡杩涚殑闂锛屼絾涓嶆槸褰撳墠 RKE2 鎺у埗骞抽潰涓嶅彲鐢ㄧ殑鐩存帴鍘熷洜銆?
鍒ゆ柇渚濇嵁锛?
- Kubernetes API 褰撳墠鍋ュ悍銆?- Rancher Pod 褰撳墠杩愯銆?- 閿欒闆嗕腑鍦?git fetch 澶栭儴浠撳簱澶辫触銆?
## 5. Rancher 椤甸潰浜哄伐鎺掓煡姝ラ

### 5.1 杩涘叆 Rancher

娴忚鍣ㄨ闂細

```text
https://192.168.1.119
```

濡傛灉璇佷功鏄嚜绛惧悕璇佷功锛屾祻瑙堝櫒鍙兘鎻愮ず涓嶅畨鍏紝闇€瑕侀€夋嫨缁х画璁块棶銆?
### 5.2 鏌ョ湅闆嗙兢鐘舵€?
璺緞锛?
```text
Cluster Management -> local
```

鎴栧湪 Rancher 棣栭〉鐩存帴杩涘叆 `local` 闆嗙兢銆?
濡傛灉椤甸潰涓樉绀哄悕涓?`rke-2` 鐨勯泦缇わ紝鍒欒繘鍏?`rke-2`锛涙湰娆″懡浠よ鎺掓煡鍦?Rancher 鍚庣鍙湅鍒?`local` 闆嗙兢瀵硅薄銆?
閲嶇偣鐪嬶細

- Cluster 鏄惁涓?Active銆?- 鏄惁鏈?Warning 鎴?Error 鏉′欢銆?- 鏈€杩戞洿鏂版椂闂存槸鍚︿笌涓绘満閲嶅惎鏃堕棿鎺ヨ繎銆?
### 5.3 鏌ョ湅鑺傜偣鏁呴殰

璺緞锛?
```text
local -> Cluster -> Nodes -> jjtestserver
```

閲嶇偣鏌ョ湅锛?
- `Conditions`
- `Events`
- `Last Heartbeat`
- `Last Transition Time`

閲嶇偣鎼滅储鎴栬瘑鍒細

- `NotReady`
- `NodeNotReady`
- `Kubelet stopped posting node status`
- `Node is unreachable`
- `Container runtime not ready`

濡傛灉杩欎簺鏃堕棿鐐逛笌 `2026-05-19 12:31` 鍒?`13:43` 鐨勪富鏈哄叧鏈虹獥鍙ｉ噸鍚堬紝灏卞彲浠ョ‘璁ゆ槸涓绘満鍋滄満寮曡捣銆?
### 5.4 鏌ョ湅寮傚父 Pod

璺緞锛?
```text
local -> Workloads -> Pods
```

绛涢€夛細

- Namespace锛歚cattle-system`
- 鐘舵€侊細闈?Running
- 鍏抽敭璇嶏細`system-upgrade-controller`

閲嶇偣鐪嬶細

- 鏄惁瀛樺湪澶ч噺 `ContainerStatusUnknown`
- Age 鏄惁闆嗕腑鍦ㄥ悓涓€鏃堕棿娈?- 鏄惁鍙湁鍘嗗彶 Pod 寮傚父锛岃€屽綋鍓?Deployment 鏈夋柊鐨?Running Pod

濡傛灉褰撳墠 Deployment 鏈?Running Pod锛屽巻鍙插紓甯?Pod 閫氬父鍙互浣滀负娈嬬暀鐘舵€佸鐞嗐€?
### 5.5 鏌ョ湅 Rancher 鏃ュ織

璺緞锛?
```text
local -> Workloads -> Deployments -> cattle-system -> rancher -> Logs
```

鎼滅储鍏抽敭璇嶏細

```text
error syncing
early EOF
fetch-pack
unexpected disconnect
broken pipe
Failed to read API
watcher channel closed
```

鍏虫敞涓ょ被閿欒锛?
1. Chart 浠撳簱鍚屾閿欒锛氶€氬父褰卞搷 Apps/Charts 椤甸潰銆?2. API watch 鎴?websocket 鐭柇锛氬鏋滃彧鍦ㄩ噸鍚獥鍙ｉ檮杩戝嚭鐜帮紝閫氬父鏄噸鍚仮澶嶈繃绋嬩腑鐨勪即闅忕幇璞★紱濡傛灉鎸佺画鍑虹幇锛屽垯闇€瑕佺户缁煡 API Server銆両ngress銆佺綉缁滄垨 Rancher 璧勬簮鍘嬪姏銆?
### 5.6 鏌ョ湅 system-upgrade-controller

璺緞锛?
```text
local -> Workloads -> Deployments -> cattle-system -> system-upgrade-controller
```

閲嶇偣鏌ョ湅锛?
- Deployment 鏄惁鏈?1 涓?Ready Pod銆?- Logs 鏄惁鏈夋寔缁姤閿欍€?- Events 鏄惁鏈?FailedScheduling銆両magePullBackOff銆丆rashLoopBackOff銆?
鏈鎺掓煡鐪嬪埌鐨勫綋鍓嶆棩蹇楁槸姝ｅ父鍚姩鍜?leader election锛?
```text
system-upgrade-controller v0.17.0 starting leader election
successfully acquired lease cattle-system/system-upgrade-controller
Starting upgrade.cattle.io/v1, Kind=Plan controller
```

## 6. 寤鸿澶勭悊椤哄簭

### 6.1 鍏堢‘璁や富鏈哄叧鏈烘潵婧?
浼樺厛纭浠ヤ笅鏉ユ簮锛?
1. 鏄惁鏈変汉鎵嬪姩鍏虫満鎴栭噸鍚湇鍔″櫒銆?2. Dell iDRAC 鏄惁閰嶇疆浜嗙數婧愯鍒掋€佺淮鎶ょ獥鍙ｆ垨杩滅▼鐢垫簮鍔ㄤ綔銆?3. 鏈烘埧銆佹彃搴с€乁PS 鏄惁鏈夋柇鐢垫垨鐢垫簮淇濇姢鍔ㄤ綔銆?4. Ubuntu 鏄惁瀛樺湪瀹氭椂鍏虫満鑴氭湰銆?5. 鏄惁鏈夎繍缁磋剼鏈皟鐢?`shutdown`銆乣reboot`銆乣poweroff`銆乣halt`銆?6. 鏄惁瀛樺湪 BIOS 灞傞潰鐨勮嚜鍔ㄥ紑鍏虫満璁剧疆銆?
寤鸿鍦ㄦ湇鍔″櫒涓婄户缁煡鐪嬶細

```bash
last -x reboot shutdown
journalctl --list-boots
journalctl -b -1 --since "2026-05-19 12:20:00" --until "2026-05-19 12:40:00"
systemctl list-timers --all
crontab -l
sudo crontab -l
grep -RInE "shutdown|reboot|poweroff|halt|rtcwake" /etc/cron* /var/spool/cron* 2>/dev/null
```

### 6.2 鍐嶅鐞?Rancher UI 涓殑寮傚父娈嬬暀

濡傛灉纭 `system-upgrade-controller` 褰撳墠 Deployment 姝ｅ父杩愯锛屼笖寮傚父 Pod 閮芥槸鍘嗗彶娈嬬暀锛屽彲浠ュ湪缁存姢绐楀彛涓竻鐞嗚繖浜涘紓甯?Pod锛岄伩鍏?Rancher 椤甸潰闀挎湡鏄剧ず澶ч噺鏁呴殰銆?
寤鸿鍏堜汉宸ョ‘璁わ細

- 褰撳墠 `system-upgrade-controller` Deployment 鏄?Ready銆?- 褰撳墠娌℃湁姝ｅ湪鎵ц鐨勫崌绾?Plan銆?- 寮傚父 Pod 鍧囦负鏃х殑 `ContainerStatusUnknown`銆?
娓呯悊鍓嶅缓璁厛瀵煎嚭娓呭崟锛?
```bash
kubectl -n cattle-system get pods | grep system-upgrade-controller
```

娓呯悊鍔ㄤ綔搴旀斁鍦ㄧ淮鎶ょ獥鍙ｆ墽琛岋紝涓嶅缓璁湪涓氬姟楂樺嘲鐩存帴鎿嶄綔銆?
### 6.3 澶勭悊 Rancher Chart 浠撳簱鍚屾闂

濡傛灉 Rancher Apps/Charts 椤甸潰寮傚父鎴?Rancher 鏃ュ織鎸佺画鍑虹幇 git fetch 澶辫触锛屽缓璁鏌ワ細

1. 鏈嶅姟鍣ㄥ埌澶栫綉 Git 浠撳簱鐨勮繛閫氭€с€?2. DNS 鏄惁绋冲畾銆?3. 鏄惁闇€瑕?HTTP/HTTPS 浠ｇ悊銆?4. 浠ｇ悊鏄惁浼氫腑鏂?HTTP/2 鎴栧ぇ鏂囦欢浼犺緭銆?5. Rancher ClusterRepo 鏄惁閰嶇疆浜嗗彲璁块棶鐨勯暅鍍忔簮銆?
杩欑被闂閫氬父涓嶄細鐩存帴瀵艰嚧宸茶繍琛屼笟鍔?Pod 宕╂簝锛屼絾浼氬奖鍝?Rancher 搴旂敤甯傚満銆丆hart 瀹夎鍜屽崌绾т綋楠屻€?
## 7. 椋庨櫓璇存槑

璇ョ幆澧冩槸鍗曡妭鐐?RKE2锛宍control-plane`銆乣etcd`銆丷ancher 鍜屼笟鍔″伐浣滆礋杞介兘鍦ㄥ悓涓€鍙版湇鍔″櫒涓娿€傚彧瑕佷富鏈哄仠鏈猴紝鏁村骞冲彴閮戒細涓嶅彲鐢紝娌℃湁鑺傜偣绾ч珮鍙敤鑳藉姏銆?
椋庨櫓锛?
- 涓绘満閲嶅惎浼氬鑷?Rancher 鍜屾墍鏈変笟鍔℃湇鍔′腑鏂€?- etcd 鍗曡妭鐐规病鏈変徊瑁佸啑浣欍€?- 涓绘満瀛樺偍銆佺綉缁溿€佺數婧愩€佺郴缁熷崌绾ч兘浼氭垚涓哄崟鐐规晠闅溿€?- 閲嶅惎鍚庡彲鑳芥畫鐣?`ContainerStatusUnknown`銆佹棫 Pod銆侀噸鍚鏁板崌楂樼瓑鐘舵€併€?
濡傛灉璇ョ幆澧冩壙杞芥寮忔垨鍑嗘寮忎笟鍔★紝寤鸿璇勪及鑷冲皯涓夎妭鐐?RKE2 鎺у埗骞抽潰锛屾垨灏嗗叧閿笟鍔¤縼绉诲埌鍏峰楂樺彲鐢ㄨ兘鍔涚殑闆嗙兢銆?
## 8. 蹇€熷垽鏂〃

| 鐜拌薄 | 浼樺厛鍒ゆ柇 | 璇佹嵁鍏ュ彛 |
|---|---|---|
| Rancher 椤甸潰鏄剧ず澶ч噺寮傚父 Pod | 鍘嗗彶寮傚父 Pod 娈嬬暀 | `cattle-system` / `system-upgrade-controller` |
| 鎵€鏈変笟鍔℃湇鍔″悓鏃朵笉鍙敤 | 涓绘満鍋滄満鎴栬妭鐐?NotReady | `last -x`銆丷ancher Nodes Events |
| RKE2 褰撳墠杩愯浣?Pod 閲嶅惎璁℃暟楂?| 涓绘満鎴栧鍣ㄨ繍琛屾椂鏇句腑鏂?| Pod Restart Count銆佺郴缁熷惎鍔ㄦ椂闂?|
| Apps/Charts 椤甸潰鍒锋柊澶辫触 | Rancher Chart 浠撳簱鍚屾澶辫触 | Rancher Deployment Logs |
| API Server 褰撳墠涓嶅彲鐢?| RKE2 鎺у埗骞抽潰寮傚父 | `/readyz`銆乣rke2-server` 鏃ュ織 |

## 9. 鏈鎺掓煡鏈墽琛岀殑鍔ㄤ綔

鏈鏈墽琛屼互涓嬪姩浣滐細

- 鏈噸鍚?RKE2銆?- 鏈垹闄や换浣?Pod銆?- 鏈慨鏀?Rancher 閰嶇疆銆?- 鏈慨鏀圭郴缁熷畾鏃朵换鍔°€?- 鏈皟鏁寸綉缁溿€丏NS 鎴栦唬鐞嗛厤缃€?- 鏈墽琛岄泦缇ゅ崌绾ф垨鍥炴粴銆?
鍚庣画濡傛灉瑕佹竻鐞嗗紓甯?Pod 鎴栬皟鏁寸郴缁熺數婧愯鍒掞紝搴斿厛纭缁存姢绐楀彛鍜屽奖鍝嶈寖鍥淬€?