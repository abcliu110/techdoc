# p.clovia.top璁块棶閾捐矾涓嶪ngress杞彂鍘熺悊璇存槑

## 1. 杩欐闂鐨勭粨璁?
`p.clovia.top` 涔嬪墠璁块棶杩斿洖 `404`锛屼笉鏄〉闈㈡枃浠舵病鏀惧锛屼篃涓嶆槸涓氬姟 Nginx 瀹瑰櫒鍧忎簡锛岃€屾槸锛?
- 鍩熷悕 `p.clovia.top` 鍏堣В鏋愬埌鍏綉鏈嶅姟鍣?`43.135.175.71`
- 鍏綉鏈嶅姟鍣ㄤ笂鐨?`frps` 鍐嶆妸 `80` 绔彛娴侀噺杞彂鍒板唴缃戞満鍣?`192.168.1.119`
- `192.168.1.119:80` 涓婂疄闄呮帴鏀惰姹傜殑鏄?`Kubernetes Ingress Nginx`
- 褰撴椂闆嗙兢閲屾病鏈?`Host = p.clovia.top` 鐨?Ingress 瑙勫垯
- 鎵€浠?Ingress 鏀跺埌璇锋眰鍚庯紝涓嶇煡閬撹杞粰鍝釜涓氬姟鏈嶅姟锛岃繑鍥炰簡榛樿 `404`

鏈淇鏂瑰紡涓嶆槸鏀?`frpc` 绔彛鏄犲皠锛岃€屾槸鍦?`119` 鏈哄櫒鐨?K8s 闆嗙兢閲屾柊澧炰簡 `Ingress` 瑙勫垯锛屾妸 `p.clovia.top` 姝ｇ‘杞彂鍒?`nms4cloud/nginx` 鏈嶅姟銆?
---

## 2. 鏁翠綋璁块棶閾捐矾

鐜板湪鐨勮闂摼璺涓嬶細

```text
娴忚鍣ㄨ闂?http://p.clovia.top
        |
        v
DNS 瑙ｆ瀽鍒?43.135.175.71
        |
        v
43.135.175.71 涓婄殑 frps 鏀跺埌 80 绔彛璇锋眰
        |
        v
閫氳繃 FRP 闅ч亾杞彂鍒?192.168.1.119:80
        |
        v
119 鏈哄櫒涓婄殑 K8s Ingress Nginx 鏀跺埌璇锋眰
        |
        v
鏍规嵁 Host = p.clovia.top 鍖归厤 Ingress 瑙勫垯
        |
        v
杞彂鍒?nms4cloud 鍛藉悕绌洪棿涓嬬殑 nginx Service:80
        |
        v
鍐嶈浆鍙戝埌 nginx Pod
        |
        v
Pod 鍐呴儴 Nginx 鏍规嵁 server_name = p.clovia.top
璇诲彇 /usr/share/nginx/html/pay 涓嬬殑闈欐€侀〉闈?        |
        v
鏈€缁堟妸椤甸潰杩斿洖缁欐祻瑙堝櫒
```

---

## 3. 姣忎竴灞傚垎鍒槸骞蹭粈涔堢殑

### 3.1 DNS

DNS 鐨勪綔鐢ㄥ氨鏄妸鍩熷悕缈昏瘧鎴?IP銆?
鏈鐜閲岋細

- `p.clovia.top` 瑙ｆ瀽鍒?`43.135.175.71`

杩欐剰鍛崇潃娴忚鍣ㄤ笉浼氱洿鎺ヨ闂?`192.168.1.119`锛岃€屾槸鍏堣闂叕缃戞満鍣?`43.135.175.71`銆?
### 3.2 FRP

FRP 鏄唴缃戠┛閫忓伐鍏凤紝鐢ㄦ潵鎶婂叕缃戣姹傝浆杩涘唴缃戞満鍣ㄣ€?
鏈鐜閲岋細

- `43.135.175.71` 涓婅窇鐨勬槸 `frps`
- `192.168.1.119` 涓婅窇鐨勬槸 `frpc`

`119` 涓婄殑 `frpc` 閰嶇疆閲岋紝鍏抽敭閮ㄥ垎鏄細

```toml
serverAddr = "43.135.175.71"
serverPort = 7000

[[proxies]]
name = "web-80"
type = "tcp"
localIP = "127.0.0.1"
localPort = 80
remotePort = 80
```

瀹冪殑鍚箟鏄細

- 鍏綉鏈嶅姟鍣?`43.135.175.71:80` 鏀跺埌鐨勬祦閲?- 閫氳繃 FRP
- 杞彂鍒?`119` 鏈哄櫒鑷繁鐨?`127.0.0.1:80`

涔熷氨鏄锛宍frpc` 鍙槸璐熻矗鈥滄妸澶栭潰鐨勮姹傞€佽繘鏉モ€濓紝瀹冧笉璐熻矗璇嗗埆鍩熷悕锛屼篃涓嶈礋璐ｅ喅瀹氳浆鍙戠粰鍝釜涓氬姟椤甸潰銆?
### 3.3 Kubernetes Ingress

Ingress 鍙互鐞嗚В涓?K8s 闆嗙兢鐨勨€滄€诲墠鍙扳€濇垨鈥滄€绘帴绾垮憳鈥濄€?
瀹冪殑鑱岃矗鏄細

- 缁熶竴鐩戝惉 `80/443`
- 鐪嬭姹傞噷甯︾殑鍩熷悕鏄粈涔?- 鍐嶅喅瀹氭妸璇锋眰杞粰鍝釜 Service

渚嬪锛?
- `Host = jjtestserver` 鏃讹紝杞粰 Rancher
- `Host = p.clovia.top` 鏃讹紝杞粰 `nms4cloud/nginx`

鎵€浠ワ紝**80 绔彛涓嶆槸琚?Rancher 鐙崰浜?*銆? 
鐪熸鐨勬儏鍐垫槸锛?
- Ingress Nginx 鍏辩敤鍚屼竴涓?`80`
- 鍐嶆牴鎹笉鍚屽煙鍚嶅垎娴佺粰涓嶅悓涓氬姟

### 3.4 Service

Service 鏄?K8s 閲屽涓€缁?Pod 鐨勭ǔ瀹氳闂叆鍙ｃ€?
鏈鐜閲岋細

- Service 鍚嶇О锛歚nms4cloud/nginx`
- Service 绔彛锛歚80`
- 瀵瑰簲鐨?Pod锛歚nginx-588d8774bd-5jj2d`

Ingress 涓嶇洿鎺ユ壘 Pod锛岃€屾槸鍏堣浆缁?Service锛屽啀鐢?Service 杞埌 Pod銆?
### 3.5 Pod 鍐呴儴涓氬姟 Nginx

涓氬姟 Nginx 鏄湡姝ｈ繑鍥為潤鎬侀〉闈㈢殑閭ｄ竴灞傘€?
瀹冪殑閰嶇疆閲屽凡缁忔湁锛?
```nginx
server {
    listen 80;
    server_name p.clovia.top;

    location / {
        root /usr/share/nginx/html/pay;
        try_files $uri $uri/ /index.html;
    }
}
```

瀹冪殑鍚箟鏄細

- 濡傛灉璇锋眰鍩熷悕鏄?`p.clovia.top`
- 灏卞幓 `/usr/share/nginx/html/pay` 鐩綍鎵鹃潤鎬侀〉闈?
鍥犳锛屼笟鍔″鍣ㄨ繖灞傚師鏈氨鏄甯哥殑銆?
---

## 4. 涓轰粈涔堜箣鍓嶄細杩斿洖 404

涔嬪墠鐨勯摼璺叾瀹炲彧宸渶鍚庣殑鈥滃垎娴佽鍒欌€濄€?
褰撴椂璇锋眰鑳芥垚鍔熻蛋鍒?`119` 鏈哄櫒锛屼絾杩涘叆 Ingress 鍚庯紝Ingress 鍙戠幇锛?
- 杩欎釜璇锋眰鐨勫煙鍚嶆槸 `p.clovia.top`
- 闆嗙兢閲屽嵈娌℃湁瀵瑰簲鐨?Ingress 瑙勫垯

浜庢槸瀹冨彧鑳借繑鍥為粯璁?404銆?
鍙互鎶婂畠鐞嗚В鎴愶細

- 蹇€掑凡缁忛€佸埌鍥尯闂ㄥ彛浜?- 浣嗛棬鍗郴缁熼噷娌℃湁鈥渀p.clovia.top` 搴旇閫佸幓鍝釜妤尖€濈殑璁板綍
- 鎵€浠ラ棬鍗嫆鏀讹紝杩斿洖 404

娉ㄦ剰锛岃繖涓?404 涓嶆槸涓氬姟椤甸潰鐩綍涓嶅瓨鍦紝鑰屾槸鍏ュ彛灞備笉鐭ラ亾璇ユ妸璇锋眰浜ょ粰璋併€?
---

## 5. 杩欐鍏蜂綋鏀逛簡浠€涔?
鏈鏂板浜嗕竴涓?Ingress锛?
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-pay
  namespace: nms4cloud
spec:
  ingressClassName: nginx
  rules:
    - host: p.clovia.top
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx
                port:
                  number: 80
```

杩欐潯瑙勫垯鐨勬剰鎬濇槸锛?
- 濡傛灉鍩熷悕鏄?`p.clovia.top`
- 閭ｄ箞鎶婅姹傝浆缁?`nms4cloud` 鍛藉悕绌洪棿閲岀殑 `nginx` 鏈嶅姟

杩欐牱锛孎RP 閫佽繘鏉ョ殑 `80` 绔彛娴侀噺锛屽氨鑳藉湪 Ingress 杩欎竴灞傝姝ｇ‘鍒嗛厤鍒颁笟鍔?Nginx銆?
---

## 6. 涓轰粈涔堜笉浼樺厛鏀?frpc 鐩磋繛 30080

褰撴椂杩樻湁涓€涓閫夋柟妗堬細

- 鎶?`frpc` 鐨?`web-80` 浠庤浆鍙戝埌鏈湴 `80`
- 鏀规垚鐩存帴杞彂鍒版湰鍦?`30080`

杩欐牱涔熻兘閫氾紝鍥犱负 `30080` 鏄笟鍔?Nginx 鐨?`NodePort`銆?
浣嗚繖涓柟妗堝彧鏄€滅洿閫氣€濓紝涓嶅鏍囧噯锛屽師鍥犳槸锛?
- 瀹冪粫杩囦簡 Ingress
- 鍚庨潰濡傛灉鍐嶅姞绗簩涓煙鍚嶏紝浼氫笉鏂逛究
- HTTPS銆佽瘉涔︺€佸绔欑偣鍏辩敤 80/443锛孖ngress 鏇撮€傚悎缁熶竴绠＄悊

鎵€浠ユ渶缁堥€夋嫨鐨勬槸鏇存爣鍑嗙殑鏂规锛?
- `frpc` 缁х画鎶婂叕缃?`80` 杞埌 `119:80`
- 鐢?Ingress 鎸夊煙鍚嶅垎娴?
---

## 7. 褰撳墠鐢熸晥鍚庣殑閾捐矾

鐜板湪閾捐矾宸茬粡鍙樻垚锛?
```text
p.clovia.top
-> 43.135.175.71:80
-> frps
-> 192.168.1.119:80
-> rke2 ingress-nginx
-> Ingress(host = p.clovia.top)
-> service nms4cloud/nginx:80
-> nginx Pod
-> /usr/share/nginx/html/pay 椤甸潰
```

楠岃瘉缁撴灉锛?
- `curl http://p.clovia.top` 杩斿洖 `200 OK`
- `curl -H "Host: p.clovia.top" http://192.168.1.119` 杩斿洖 `200 OK`

璇存槑鍏綉鍩熷悕璁块棶鍜岄泦缇ゅ唴閮ㄥ煙鍚嶅垎娴侀兘宸茬粡姝ｅ父銆?
---

## 8. 浠ュ悗閬囧埌绫讳技闂鎬庝箞鎺掓煡

浠ュ悗濡傛灉鍐嶆鍑虹幇鍩熷悕璁块棶寮傚父锛屽彲浠ユ寜杩欎釜椤哄簭鎺掓煡锛?
### 绗竴姝ワ細鐪?DNS

纭鍩熷悕瑙ｆ瀽鍒板摢閲岋細

```bash
nslookup p.clovia.top
```

濡傛灉娌℃湁瑙ｆ瀽鍒伴鏈熷叕缃?IP锛岃鍏堟煡 DNS銆?
### 绗簩姝ワ細鐪?FRP

纭 `frpc` 鏄惁姝ｅ父杩炴帴銆佺鍙ｆ槸鍚︽槧灏勬纭細

```bash
systemctl status frpc
sed -n '1,200p' /etc/frp/frpc.toml
```

閲嶇偣纭锛?
- `serverAddr`
- `remotePort`
- `localPort`

### 绗笁姝ワ細鐪?Ingress

纭鏄惁瀛樺湪瀵瑰簲鍩熷悕瑙勫垯锛?
```bash
kubectl get ingress -A
kubectl describe ingress nginx-pay -n nms4cloud
```

閲嶇偣纭锛?
- `host` 鏄惁涓?`p.clovia.top`
- `backend service` 鏄惁鎸囧悜姝ｇ‘鏈嶅姟

### 绗洓姝ワ細鐪?Service 鍜?Pod

```bash
kubectl get svc -n nms4cloud
kubectl get pod -n nms4cloud -o wide
```

閲嶇偣纭锛?
- Service 鏄惁瀛樺湪
- Pod 鏄惁鏄?`Running`
- Service 鍚庣鏄惁鎸囧悜姝ｇ‘ Pod

### 绗簲姝ワ細鐪嬩笟鍔?Nginx 閰嶇疆鍜岄〉闈㈢洰褰?
杩涘叆 Pod 妫€鏌ワ細

```bash
kubectl exec -it <pod-name> -n nms4cloud -- sh
ls /etc/nginx/conf.d
ls /usr/share/nginx/html
```

閲嶇偣纭锛?
- `server_name` 鏄惁姝ｇ‘
- `root` 鎸囧悜鐨勭洰褰曟槸鍚﹀瓨鍦?- 闈欐€佹枃浠舵槸鍚︾湡鐨勫湪瀵瑰簲鐩綍涓?
---

## 9. 涓€鍙ヨ瘽鎬荤粨

杩欐闂鐨勬湰璐ㄤ笉鏄€滈〉闈㈡斁閿欑洰褰曗€濓紝鑰屾槸鈥滃叕缃戣姹傚凡缁忚繘鍒伴泦缇ゅ叆鍙ｏ紝浣嗗叆鍙ｅ眰缂哄皯 `p.clovia.top` 鐨勫垎娴佽鍒欌€濄€? 
鏈閫氳繃鏂板 K8s Ingress锛屾妸 `p.clovia.top` 姝ｇ‘杞彂鍒颁笟鍔?Nginx锛岄棶棰樺凡缁忚В鍐炽€?
