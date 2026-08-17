rd "libs/" /s /q
rd "printerlibs/" /s /q
rd "libs6/" /s /q
rd "dist/" /s /q

xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-pos1starter-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-pos2plugin-api-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-pos2plugin-biz-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-pos2plugin-dal-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-pos3boot-api-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-pos3boot-biz-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-pos3boot-dal-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-starter-mybatis-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-starter-mybatis-flex-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-starter-parent-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\libs\nms4cloud-starter-redis-0.0.1-SNAPSHOT.jar" "libs\"

xcopy /s /Y "..\2_nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\target\nms4cloud-pos3boot-app-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-api\target\nms4cloud-pos4cloud-api-0.0.1-SNAPSHOT.jar" "libs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos5sync\nms4cloud-pos5sync-api\target\nms4cloud-pos5sync-api-0.0.1-SNAPSHOT.jar" "libs\"


xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-pos1starter-0.0.1-SNAPSHOT.jar" "printerlibs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-pos2plugin-api-0.0.1-SNAPSHOT.jar" "printerlibs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-starter-mybatis-0.0.1-SNAPSHOT.jar" "printerlibs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-starter-mybatis-flex-0.0.1-SNAPSHOT.jar" "printerlibs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-starter-parent-0.0.1-SNAPSHOT.jar" "printerlibs\"


xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-pos10printer-api-0.0.1-SNAPSHOT.jar" "printerlibs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-pos10printer-biz-0.0.1-SNAPSHOT.jar" "printerlibs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\libs\nms4cloud-pos10printer-dal-0.0.1-SNAPSHOT.jar" "printerlibs\"
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\target\nms4cloud-pos10printer-app-0.0.1-SNAPSHOT.jar" "printerlibs\"



xcopy /s /Y "..\2_nms4pos\nms4cloud-pos6monitor\target\nms4cloud-pos6monitor-0.0.1-SNAPSHOT.jar" "libs6\"


"C:\Program Files (x86)\Inno Setup 5"\Compil32.exe  /cc ".\setup.iss"

"C:\Program Files (x86)\Inno Setup 5"\Compil32.exe  /cc ".\patch.iss"

"C:\Program Files (x86)\Inno Setup 5"\Compil32.exe  /cc ".\setupGzjj.iss"

"C:\Program Files (x86)\Inno Setup 5"\Compil32.exe  /cc ".\patchGzjj.iss"

"C:\Program Files (x86)\Inno Setup 5"\Compil32.exe  /cc ".\setupSenHai.iss"


