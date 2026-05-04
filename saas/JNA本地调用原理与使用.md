# JNA 本地调用原理与使用

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos2plugin-biz、pos6monitor
> 最后更新：2026-04-30

---

## 一、组件概述

**JNA**（Java Native Access，`net.java.dev.jna:jna`）允许 Java 代码直接调用本地（C/C++）动态链接库（DLL/SO），无需 JNI 编写 C 代码。在 nms4pos 中，JNA 用于调用厂商提供的打印机 SDK（DLL）或硬件驱动：

- **热敏打印机厂商 SDK**：调用厂商提供的 DLL 实现特定功能（如钱箱弹出、打印机自检）
- **电子秤**：读取秤的读数
- **条码枪**：获取扫码数据

**JNA vs JNI 对比**：

| 维度 | JNA | JNI |
|------|-----|-----|
| 代码量 | 少（纯 Java） | 多（需要 C 代码） |
| 学习成本 | 低 | 高 |
| 性能 | 略低（多一层调用） | 接近原生 |
| 可维护性 | 高（纯 Java） | 低（C 代码需单独编译） |
| 适用场景 | 调用已有 DLL | 需要极致性能 |

---

## 二、Maven 依赖

**pos2plugin-biz**（`nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/pom.xml`）：

```xml
<!-- JNA -->
<dependency>
    <groupId>net.java.dev.jna</groupId>
    <artifactId>jna</artifactId>
    <version>5.12.1</version>
</dependency>
```

**pos6monitor**（`nms4cloud-pos6monitor/pom.xml`）：通过本地 `lib/` 目录引入：

```xml
<!-- jna-platform（system scope，本地 jar） -->
<dependency>
    <groupId>net.java.dev.jna</groupId>
    <artifactId>jna-platform</artifactId>
    <version>5.17.0</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/lib/jna-platform-5.17.0.jar</systemPath>
</dependency>
```

---

## 三、核心使用方式

### 3.1 定义 native 接口

```java
import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Pointer;

// 定义 C DLL 的函数接口
public interface ThermalPrinterSDK extends Library {

    // 获取 SDK 实例
    ThermalPrinterSDK INSTANCE = Native.load(
        "ThermalPrinterSDK",   // Windows: ThermalPrinterSDK.dll
                               // Linux:   libThermalPrinterSDK.so
        ThermalPrinterSDK.class
    );

    // 初始化打印机
    int initPrinter(int portType, String portName);

    // 打开钱箱
    int openCashDrawer();

    // 获取打印机状态
    int getPrinterStatus();

    // 打印文本
    int printText(String text);

    // 切纸
    int cutPaper();

    // 获取固件版本
    String getFirmwareVersion();
}
```

### 3.2 调用 DLL 函数

```java
@Service
public class PrinterNativeService {

    private ThermalPrinterSDK sdk;

    @PostConstruct
    public void init() {
        sdk = ThermalPrinterSDK.INSTANCE;
    }

    public boolean openCashDrawer() {
        try {
            int result = sdk.openCashDrawer();
            if (result == 0) {
                log.info("钱箱打开成功");
                return true;
            } else {
                log.error("钱箱打开失败，错误码: {}", result);
                return false;
            }
        } catch (UnsatisfiedLinkError e) {
            log.error("加载打印机 DLL 失败: {}", e.getMessage());
            return false;
        }
    }

    public int getPrinterStatus() {
        try {
            return sdk.getPrinterStatus();
        } catch (Exception e) {
            log.error("获取打印机状态失败", e);
            return -1;
        }
    }
}
```

### 3.3 结构体映射（C struct → Java）

```java
import com.sun.jna.Structure;
import com.sun.jna.Structure.FieldOrder;

// C 结构体映射
@Structure.FieldOrder({"status", "paper", "temperature", "version"})
public class PrinterStatus extends Structure {
    public int status;       // 状态码
    public int paper;        // 纸张状态（0=正常，1=缺纸）
    public int temperature;   // 打印头温度
    public byte[] version = new byte[32]; // 固件版本

    // JNA 要求无参构造函数
    public PrinterStatus() {}
}

// 调用返回结构体的函数
public PrinterStatus queryStatus() {
    PrinterStatus status = new PrinterStatus();
    sdk.queryPrinterStatus(status);
    return status;
}
```

### 3.4 回调函数（callback）

```java
import com.sun.jna.Callback;
import com.sun.jna.CallbackThreadInitializer;

// C 回调接口定义
public interface PrinterCallback extends Callback {
    void onEvent(int eventType, String message);
}

// 设置回调
public void setPrinterCallback() {
    sdk.setEventCallback(new PrinterCallback() {
        @Override
        public void onEvent(int eventType, String message) {
            log.info("打印机事件: type={}, msg={}", eventType, message);
            if (eventType == 1) {
                // 缺纸告警
                alertService.alertPaperOut();
            }
        }
    });
}
```

---

## 四、pos6monitor 中的 JNA 使用

pos6monitor 是系统监控模块，通过 JNA 监控串口外设状态：

```
pos6monitor 监控流程：
传感器数据采集（JNA 调用 DLL 读取传感器）
  → 数据处理
  → 告警判断（纸张/钱箱/连接状态）
  → WebFlux 实时推送
```

---

## 五、DLL 部署

| 平台 | DLL 位置 | 加载方式 |
|------|---------|---------|
| Windows | `C:\Windows\System32\` 或应用目录 | `Native.load("ThermalPrinterSDK", ...)` |
| Linux | `/usr/lib/` 或应用 `lib/` 目录 | `Native.load("libThermalPrinterSDK.so", ...)` |
| Docker | 挂载到容器内 `/usr/local/lib/` | 需要在 Dockerfile 中 COPY DLL |

---

## 六、注意事项

1. **位数匹配**：Java 进程的位数（32/64）必须与 DLL 一致
2. **DLL 依赖传递**：被调用的 DLL 可能有自身的依赖（如 VC++ 运行库），需要一并部署
3. **跨平台**：Windows DLL 不能在 Linux 上使用，需要分别为各平台编译
4. **错误处理**：`UnsatisfiedLinkError` 表示 DLL 加载失败，常见原因：文件不存在、位数不匹配、依赖缺失

---

## 七、相关文档

- [jSerialComm与RXTX串口通信](./jSerialComm与RXTX串口通信.md) — 串口通信基础
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)