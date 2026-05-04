# p.clovia.top 鏀粯浜岀淮鐮佸叏閾捐矾鍘熺悊涓庣粍浠堕€氫俊璇存槑

## 1. 鏂囨。鐩殑

鏈枃璇存槑浠ヤ笅闂锛?
- 鐢ㄦ埛璁块棶 `http://p.clovia.top/?S=...&M=...&B=...` 鍚庯紝绯荤粺鍐呴儴鍒板簳鍙戠敓浜嗕粈涔?- 姣忎釜缁勪欢鍒嗗埆璐熻矗浠€涔?- 鍚勭粍浠朵箣闂撮€氳繃浠€涔堝崗璁€氫俊
- 涓轰粈涔堜箣鍓嶄細鍑虹幇 `over time`
- 涓轰粈涔堝綋鍓嶅凡缁忔仮澶嶆甯?- 鍦?`useNettyService=false` 妯″紡涓嬶紝浠€涔堟儏鍐典笅鑳介€氾紝浠€涔堟儏鍐典笅涓嶈兘閫?
---

## 2. 鏈鏈€缁堢粨璁?
鏈閾捐矾褰撳墠宸茬粡鎭㈠姝ｅ父銆? 
鏈€鏂板疄娴嬬粨鏋滐細

- 璁块棶鏀粯鍑虹爜鎺ュ彛鏃讹紝`nms4cloud-mq` 鑳藉湪绾?`1.85s` 鍐呰繑鍥?`qr_code`
- `mq` 鏃ュ織涓凡缁忚兘鐪嬪埌锛?  - `get_qrcode_from_offline: GenQrcodeForBill:netty_...`
  - `receive_qrcode_from_offline: {"qr_code":"..."}`
- `mq` 鏈湴宸茬粡鑳芥煡鍒?topic锛?  - `1942885905090105345_server`

杩欒鏄庡綋鍓嶆ā寮忔槸锛?
- `mq` 鑷繁鍐呯疆鐨?Netty 宸茬粡宸ヤ綔
- POS 宸茬粡鎶婇棬搴?topic 娉ㄥ唽鍒颁簡 `mq` 鏈湴
- 鎵€浠?`useNettyService=false` 鐨勬湰鍦扮洿杩炴ā寮忓凡缁忔墦閫?
---

## 3. 鏁翠綋閾捐矾鎬昏

褰撳墠瀹屾暣璋冪敤閾惧涓嬶細

```text
娴忚鍣?-> p.clovia.top 闈欐€佹敮浠橀〉
-> 鍓嶇瑙ｆ瀽 URL 涓殑 S / M / B
-> 璇锋眰 /api/pay/pay_channel/isOpenIdNeeded
-> 璇锋眰 /api/mq/pay/get_qrcode_from_offline
-> nms4cloud-mq 鐢熸垚 GenQrcodeForBill 娑堟伅
-> mq 鍐呯疆 Netty 鎶婃秷鎭帹閫佺粰 POS
-> POS 鏈湴 9180 鎺ュ彛 /merchant/dwd_bill_ops/createQrcode 澶勭悊
-> POS 鏈湴鐢熸垚浜岀淮鐮?-> POS 鍥炶皟浜戠 /api/sc/pay/receive_qrcode_from_offline
-> mq 鏀跺埌鍥炶皟骞跺敜閱掔瓑寰呬腑鐨?HTTP 璇锋眰
-> mq 鎶?qr_code 杩斿洖缁欏墠绔?-> 鍓嶇璺宠浆鍒颁簩缁寸爜鏀粯椤垫垨鎷夎捣寰俊鏀粯
```

---

## 4. 鍚勭粍浠惰亴璐?
### 4.1 娴忚鍣?/ H5 椤甸潰

鑱岃矗锛?
- 灞曠ず鏀粯鍔犺浇椤?- 瑙ｆ瀽 URL 鍙傛暟
- 璋冪敤鍚庣鎺ュ彛鑾峰彇浜岀淮鐮?- 鏍规嵁杩斿洖缁撴灉缁х画璺宠浆鎴栨媺璧锋敮浠?
瀵瑰簲浠ｇ爜锛?
- `D:\mywork\uni4pay\src\pages\index\index.vue`
- `D:\mywork\uni4pay\src\service\pay\index.ts`

鏍稿績閫昏緫锛?
1. 浠?URL 涓彇鍑?`S`銆乣M`銆乣B`
2. 濡傛灉鏈?`M`锛屽厛鎶?`S` 鍜?`M` 浠?base62 杞负鍗佽繘鍒?3. 璋?`needOpenId(sid)`
4. 濡傛灉涓嶉渶瑕?openid锛岀洿鎺ヨ皟 `queryQrCode(...)`
5. 濡傛灉杩斿洖鐨勬槸浜岀淮鐮佽烦杞湴鍧€锛屽氨鐩存帴 `window.location.href = qr_code`
6. 濡傛灉杩斿洖鐨勬槸鏀粯鍗曞彿锛屽啀缁х画璋?`getPayInfo(...)`

---

### 4.2 涓氬姟 Nginx

鑱岃矗锛?
- 鎻愪緵鏀粯椤甸潤鎬佽祫婧?- 鎶?`/api/**` 浠ｇ悊鍒扮綉鍏?
宸茬‘璁ら厤缃細

- `server_name p.clovia.top`
- 闈欐€佺洰褰曪細`/usr/share/nginx/html/pay`

杩欏眰鍙礋璐ｏ細

- 椤甸潰鏂囦欢
- API 鍙嶅悜浠ｇ悊鍏ュ彛

瀹冧笉璐熻矗鐢熸垚浜岀淮鐮侊紝涔熶笉璐熻矗鍜?POS 閫氫俊銆?
---

### 4.3 Ingress / FRP / 鍩熷悕鍏ュ彛

鑱岃矗锛?
- 鎶婂叕缃戣姹傞€佸埌 `119` 鏈哄櫒
- 鍐嶈繘鍏?K8s 鍐呴儴鐨?`nginx` 鏈嶅姟

褰撳墠瀹為檯鍏ュ彛缁撴瀯锛?
```text
p.clovia.top
-> 鍏綉 43.135.175.71
-> frps/frpc
-> 192.168.1.119:80
-> K8s Ingress
-> nms4cloud/nginx
```

杩欏眰鍙喅瀹氣€滆姹傝兘涓嶈兘杩涙潵鈥濓紝涓嶈礋璐ｆ敮浠樹笟鍔￠€昏緫銆?
---

### 4.4 Gateway

鑱岃矗锛?
- 鎺ユ敹鍓嶇鐨?`/api/**` 璇锋眰
- 鏍规嵁璺敱瑙勫垯鎶婅姹傚垎鍙戝埌涓嶅悓寰湇鍔?
鏈鏀粯鐩稿叧鐨勪袱涓叧閿帴鍙ｅ垎鍒惤鍒帮細

- `/api/pay/pay_channel/isOpenIdNeeded`
  - 杞埌 `nms4cloud-payment`
- `/api/mq/pay/get_qrcode_from_offline`
  - 杞埌 `nms4cloud-mq`

璇存槑锛?
- `needOpenId` 鐨勬帶鍒跺櫒鍦?`PayChannelController`
- `get_qrcode_from_offline` 鐨勬帶鍒跺櫒鍦?`GetQrCodeFromOffline`

鍏朵腑 `/api/mq/pay/get_qrcode_from_offline` 鐨勭綉鍏冲叿浣?rewrite 瑙勫垯鏈湪鏈浠ｇ爜鎼滅储閲岀洿鎺ヨ鍒帮紝浣嗕粠鎺ュ彛瀹炴祴鎴愬姛銆佹湇鍔℃帶鍒跺櫒璺緞鍜岀幇缃戣涓哄彲浠ョ‘璁わ細

- 缃戝叧鏈€缁堟妸璇锋眰姝ｇ‘钀藉埌浜?`mq` 鏈嶅姟鐨?`/pay/get_qrcode_from_offline`

杩欐潯缁撹灞炰簬鈥滆繍琛岄獙璇佹敮鎸佺殑鎺ㄦ柇鈥濄€?
---

### 4.5 nms4cloud-payment

鑱岃矗锛?
- 鍒ゆ柇鎸囧畾闂ㄥ簵鏀粯閫氶亾鏄惁闇€瑕?openid

瀵瑰簲浠ｇ爜锛?
- `PayChannelController.isOpenIdNeeded`

浣滅敤锛?
- 鍓嶇涓嶆槸涓€涓婃潵灏卞幓鍑虹爜
- 鍏堥棶鏀粯閰嶇疆锛氳繖涓棬搴楅€氶亾鏄惁瑕佹眰鍏紬鍙?openid
- 濡傛灉涓嶉渶瑕侊紝鐩存帴寰€鍚庤蛋
- 濡傛灉闇€瑕侊紝鍓嶇鍏堣蛋鍏紬鍙锋巿鏉冿紝鍐嶇户缁嚭鐮?
鏈杩欑粍鍙傛暟瀹炴祴锛?
- `isOpenIdNeeded` 寰堝揩杩斿洖 `false`

鎵€浠ユ湰娆￠棶棰樹笉鍦ㄨ繖涓€姝ャ€?
---

### 4.6 nms4cloud-mq

鑱岃矗锛?
- 鎺ユ敹鈥滀粠绾夸笅鑾峰彇鏀粯浜岀淮鐮佲€濈殑 HTTP 璇锋眰
- 鐢熸垚涓€鏉?`GenQrcodeForBill` Netty 娑堟伅鍙戠粰 POS
- 鎸傝捣褰撳墠 HTTP 璇锋眰锛岀瓑寰?POS 鍥炲寘
- 鏀跺埌鍥炲寘鍚庡啀鎶婄粨鏋滆繑鍥炵粰鍓嶇

瀵瑰簲浠ｇ爜锛?
- `GetQrCodeFromOffline.java`
- `ReceiveQrCodeFromOffline.java`
- `MonoMgr.java`
- `ServerHandler.java`
- `ListenerForNetty.java`
- `NettyServer.java`

鍏抽敭閫昏緫锛?
1. 鏀跺埌 `/pay/get_qrcode_from_offline`
2. 鏋勯€犳秷鎭細

```json
{
  "Cmd": "GenQrcodeForBill",
  "Topic": "1942885905090105345_server",
  "BillId": "2049382606410010626",
  "MsgID": "netty_xxx",
  "isAlipay": false
}
```

3. 鎶婅繖鏉℃秷鎭彂缁?Netty
4. 鎶?`MsgID` 鏀捐繘 `MonoMgr`
5. 褰撳墠 HTTP 璇锋眰涓嶉┈涓婄粨鏉燂紝鑰屾槸绛夊緟鍥炶皟

濡傛灉 20 绉掑唴娌℃湁鏀跺埌鍥炶皟锛宍MonoMgr` 浼氫富鍔ㄨ繑鍥烇細

```json
{"code":-1,"errorMessage":"over time"}
```

---

## 5. mq 鍐呯疆 Netty 鐨勪綔鐢?
### 5.1 鍚姩鏂瑰紡

`mq` 鍚姩鏃朵細鑷姩鎷夎捣涓ら儴鍒嗭細

- `NettyServer`
- `NettyClient`

瀵瑰簲浠ｇ爜锛?
- `ListenerForNetty.contextInitialized()`

涔熷氨鏄锛屽彧瑕?`mq` 鍚姩锛岃繖涓簲鐢ㄥ唴閮ㄥ氨浼氭妸鑷繁鐨?Netty 閫氫俊鑳藉姏涓€璧峰甫璧锋潵銆?
### 5.2 NettyServer 鍋氫粈涔?
`NettyServer` 浼氬湪鏈繘绋嬮噷鐩戝惉 `9999` 绔彛銆?
浣滅敤锛?
- 鎺ユ敹 POS 璁惧鐨?Netty 闀胯繛鎺?- 缁存姢 topic 鍒拌繛鎺ヤ笂涓嬫枃鐨勬槧灏勫叧绯?- 鎶婃潵鑷?`mq` 鐨勫懡浠よ浆鍙戠粰瀵瑰簲 POS

瀵瑰簲浠ｇ爜锛?
- `NettyServer.start()`

### 5.3 topic 鏄粈涔?
鍙互鎶?topic 鐞嗚В涓猴細

- 鏌愬彴 POS 鎴栨煇涓棬搴楀湪 Netty 绯荤粺閲岀殑鈥滄敹浠剁鍚嶇О鈥?
渚嬪锛?
- `1942885905090105345_server`

琛ㄧず闂ㄥ簵 `sid=1942885905090105345` 瀵瑰簲鐨勬秷鎭闃呬富棰樸€?
鍙 POS 杩炰笂鏉ュ苟鎴愬姛璁㈤槄杩欎釜 topic锛宍mq` 鎵嶇煡閬撴秷鎭鍙戠粰鍝彴 POS銆?
---

## 6. POS 绔浣曟帴鏀舵秷鎭?
瀵瑰簲浠ｇ爜锛?
- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\client\NettyClient.java`
- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\client\ClientHandler.java`

### 6.1 POS 鍚姩鍚庡仛浠€涔?
POS 鏈湴浼氫富鍔ㄨ繛鍒?Netty 鏈嶅姟锛?
- `host = netty.host`
- `port = netty.port`

杩炰笂鍚庝細鍙戦€佽闃呮秷鎭細

```json
{
  "Cmd": "subscribe",
  "Topic": [
    "璁惧UUID_server",
    "1942885905090105345_server"
  ]
}
```

涔熷氨鏄锛孭OS 涓嶄細绛夊緟浜戠涓诲姩鎵惧畠锛岃€屾槸鑷繁鍏堝缓闀胯繛鎺ワ紝鍐嶅憡璇夋湇鍔＄鈥滄垜璐熻矗杩欎簺 topic鈥濄€?
### 6.2 POS 鏀跺埌 `GenQrcodeForBill` 鍚庡仛浠€涔?
POS 绔?`ClientHandler` 涓啓姝讳簡鍛戒护鏄犲皠锛?
```text
GenQrcodeForBill -> /merchant/dwd_bill_ops/createQrcode
```

杩欒〃绀猴細

- 浜戠鍙戞潵鐨?`GenQrcodeForBill`
- 浼氳 POS 杞垚鏈満 HTTP 璇锋眰
- 璇锋眰鎵撳埌鏈湴 `127.0.0.1:9180/merchant/dwd_bill_ops/createQrcode`

---

## 7. POS 鏈湴 9180 鎺ュ彛鍋氫粈涔?
瀵瑰簲浠ｇ爜锛?
- `DwdBillOpsForBizController.createQrcode`
- `DwdBillOpsServiceImpl.createQrcode`

涓昏閫昏緫锛?
1. 鏍规嵁 `billId` 鏌ユ湰鍦拌鍗?2. 鍒ゆ柇璁㈠崟鏄惁宸茬粨璐?3. 鍒ゆ柇鏀粯鏂瑰紡鏄惁宸插瓨鍦?4. 蹇呰鏃跺垱寤烘敮浠樻柟寮忋€佸垱寤烘敮浠樼敵璇峰崟
5. 璋?`OrderServiceUtil.createQrcode(...)` 鐢熸垚鏀粯浜岀淮鐮?6. 鐢熸垚鍚庢妸 `qr_code` 鍖呰鎴?JSON
7. 璋?`resToOnLine(data, msgID)` 鎶婄粨鏋滃洖鎺ㄤ簯绔?
杩欎竴姝ユ墠鏄湡姝ｂ€滅嚎涓嬪嚭鐮佲€濆彂鐢熺殑鍦版柟銆?
---

## 8. POS 濡備綍鎶婁簩缁寸爜缁撴灉鍥炴帹浜戠

瀵瑰簲浠ｇ爜锛?
- `DwdBillOpsServiceImpl.resToOnLine`

閫昏緫锛?
POS 鏈湴鐢熸垚浜岀淮鐮佸悗锛屼細鍙?HTTP POST 鍒帮細

```text
{apiServer}/api/sc/pay/receive_qrcode_from_offline
```

璇锋眰浣撻噷鍖呭惈锛?
- `MsgId`
- `data`
  - 閲岄潰鏈?`qr_code`

涔熷氨鏄锛孭OS 涓嶆槸閫氳繃娴忚鍣ㄧ洿鎺ュ洖椤甸潰锛岃€屾槸锛?
- 鍏堟妸浜岀淮鐮佺粨鏋滃洖缁欎簯绔?`mq`
- 鍐嶇敱 `mq` 鎶婄瓑寰呬腑鐨?HTTP 璇锋眰鍞ら啋

---

## 9. mq 濡備綍鎶婂洖鍖呰繕缁欏墠绔?
瀵瑰簲浠ｇ爜锛?
- `ReceiveQrCodeFromOffline.java`
- `MonoMgr.java`

娴佺▼锛?
1. `mq` 鏀跺埌 `/pay/receive_qrcode_from_offline`
2. 鐢?`MsgId` 鎷煎嚭 Redis key锛?
```text
GenQrcodeForBill:{msgId}
```

3. 鎶婁簩缁寸爜 JSON 鍐欏叆 Redis
4. `MonoMgr` 鐨勫畾鏃朵换鍔℃瘡绉掓鏌ヤ竴娆?5. 涓€鏃﹀彂鐜?Redis 閲屾湁瀵瑰簲缁撴灉锛岄┈涓婅Е鍙戝洖璋?6. 鍘熸湰鎸傝捣鐨?`/pay/get_qrcode_from_offline` HTTP 璇锋眰绔嬪嵆杩斿洖

浜庢槸鍓嶇灏辨敹鍒颁簡锛?
```json
{"qr_code":"https://openapi.tianquetech.com/frontNew/trade/?id=..."}
```

---

## 10. `useNettyService=false` 鍜?`true` 鐨勫尯鍒?
### 10.1 `false` 妯″紡

鍚箟锛?
- `mq` 涓嶈蛋鐙珛 `nms4cloud-netty` 鏈嶅姟
- 鍙娇鐢ㄨ嚜宸辨湰鍦扮殑 Netty topic 琛?
鍙湁褰撲笅闈㈡潯浠舵垚绔嬫椂鎵嶄細閫氾細

- POS 鐩存帴杩炵殑鏄?`mq` 鑷甫鐨?Netty
- POS 璁㈤槄宸茬粡娉ㄥ唽鍦?`mq` 鏈湴

杩欏氨鏄€滄湰鍦颁竴浣撳寲閮ㄧ讲鍙互閫氣€濈殑鍘熷洜銆?
### 10.2 `true` 妯″紡

鍚箟锛?
- `mq` 涓嶇洿鎺ョ湅鑷繁鏈湴 topic 琛?- 鑰屾槸閫氳繃 `NettyReactiveFeign` 鎶婃秷鎭彂缁欑嫭绔嬬殑 `nms4cloud-netty` 鏈嶅姟

閫傚悎锛?
- `mq` 鍜?`netty` 鍒嗗紑閮ㄧ讲
- POS 缁熶竴杩炵嫭绔?`netty` 鏈嶅姟

---

## 11. 涓轰粈涔堜箣鍓嶄細 `over time`

涔嬪墠闂鐨勬牴鍥犱笉鏄細

- 鍓嶇 URL 閿?- Ingress 閿?- 闈欐€侀〉闈㈢洰褰曢敊
- 鏀粯鎺ュ彛瀹屽叏璁块棶涓嶅埌

涔嬪墠鐪熸鐨勯棶棰樻槸锛?
- `mq` 褰撴椂鍦?`false` 妯″紡涓嬪彂閫?`GenQrcodeForBill`
- 浣?`mq` 鏈湴娌℃湁鎷垮埌闂ㄥ簵 topic 璁㈤槄
- 鎵€浠ユ秷鎭病鏈夌湡姝ｅ彂鍒?POS
- `mq` 涓€鐩寸瓑涓嶅埌 `/pay/receive_qrcode_from_offline`
- 20 绉掑悗 `MonoMgr` 杩斿洖 `over time`

涔熷氨鏄細

```text
璇锋眰杩涘叆 mq
-> mq 鐢熸垚娑堟伅
-> 鐩爣 topic 褰撴椂涓嶅湪 mq 鏈湴
-> POS 娌℃敹鍒?-> 娌℃湁鍥炲寘
-> mq 瓒呮椂
```

---

## 12. 涓轰粈涔堢幇鍦ㄦ仮澶嶆甯?
褰撳墠鎭㈠姝ｅ父鐨勫叧閿潯浠舵槸锛?
- `mq` 鏈湴宸茬粡鑳芥煡鍒帮細
  - `1942885905090105345_server`
- 鍑虹爜鎺ュ彛宸茬粡鑳藉湪绾?`1.85s` 鍐呰繑鍥?`qr_code`
- `mq` 鏃ュ織閲屽凡缁忚兘鐪嬪埌鍥炶皟锛?  - `receive_qrcode_from_offline`

杩欒〃绀哄綋鍓嶉摼璺凡缁忓彉鎴愶細

```text
鍓嶇璇锋眰
-> mq
-> mq 鏈湴 Netty
-> POS
-> POS 鏈湴 9180 createQrcode
-> POS 鍥炶皟 mq
-> mq 杩斿洖 qr_code
```

鍥犳锛屽綋鍓?`useNettyService=false` 妯″紡宸茬粡鍏峰杩愯鏉′欢銆?
---

## 13. 鍚勭粍浠堕€氫俊鏂瑰紡姹囨€?
### 13.1 娴忚鍣?-> Nginx

- 鍗忚锛欻TTP
- 鍐呭锛氳姹傞潤鎬侀〉銆佽姹?`/api/**`

### 13.2 Nginx -> Gateway

- 鍗忚锛欻TTP 鍙嶅悜浠ｇ悊
- 鍐呭锛氳浆鍙?`/api/**`

### 13.3 Gateway -> payment / mq

- 鍗忚锛欻TTP
- 鍐呭锛?  - `/api/pay/pay_channel/isOpenIdNeeded`
  - `/api/mq/pay/get_qrcode_from_offline`

### 13.4 mq -> POS

- 鍗忚锛歂etty TCP 闀胯繛鎺?- 鍐呭锛歚GenQrcodeForBill`

### 13.5 POS -> POS 鏈湴涓氬姟

- 鍗忚锛氭湰鏈?HTTP
- 鍦板潃锛歚127.0.0.1:9180`
- 璺緞锛歚/merchant/dwd_bill_ops/createQrcode`

### 13.6 POS -> mq 鍥炶皟

- 鍗忚锛欻TTP
- 璺緞锛歚/api/sc/pay/receive_qrcode_from_offline`

### 13.7 mq 鍐呴儴绛夊緟鏈哄埗

- 鏈哄埗锛歚Mono + Redis + 瀹氭椂杞`

---

## 14. 涓€鍙ヨ瘽鎬荤粨

杩欏鏀粯浜岀淮鐮侀摼璺殑鏈川鏄細

- 鍓嶇鍙礋璐ｅ彂璧封€滄垜瑕佷簩缁寸爜鈥?- `mq` 璐熻矗鎶婅姹傝浆鎴?`GenQrcodeForBill`
- POS 璐熻矗鐪熸鐢熸垚浜岀淮鐮?- POS 鍐嶆妸缁撴灉鍥炶皟缁?`mq`
- `mq` 鍐嶆妸缁撴灉杩樼粰鍓嶇

褰撳墠浣犺繖濂楃幆澧冧箣鎵€浠ヨ兘閫氾紝鏄洜涓猴細

- 浣犲疄闄呰窇鐨勬槸 `useNettyService=false` 鐨勬湰鍦扮洿杩炴ā寮?- 骞朵笖 POS 鐨勯棬搴?topic 宸茬粡鎴愬姛娉ㄥ唽鍒?`mq` 鏈湴

濡傛灉浠ュ悗鍙堝嚭鐜?`over time`锛屾渶鍏堟鏌ョ殑涓嶆槸椤甸潰锛岃€屾槸锛?
- `mq` 鏈湴杩樿兘涓嶈兘鏌ュ埌 `1942885905090105345_server`

鏌ヤ笉鍒帮紝灏辫鏄庯細

- POS 娌℃湁鐪熸鎸傚埌 `mq` 鏈湴 Netty 涓?- 杩欐椂鍓嶇涓€瀹氫細瓒呮椂銆?
