# jSerialComm 与 RXTX 串口通信

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos1starter、pos2plugin-biz、pos6monitor
> 核心源文件：`PortHandler.java`（1913行）
> 最后更新：2026-04-30

---

## 一、组件概述

nms4pos 的核心使命之一是连接热敏小票打印机、钱箱等外设。两套串口库并存：

| 组件 | 版本 | 引用方式 | 建议 |
|------|------|---------|------|
| **jSerialComm** | 2.10.2 / 2.11.0 | Maven 仓库 | ✅ 推荐，新一代跨平台库 |
| **RXTXcomm** | 2.1.7 | `system` scope，本地 `lib/` | ⚠️ 遗留库，逐步废弃 |

**jSerialComm**（`com.fazecast:jSerialComm`）是新一代跨平台串口通信库，纯 Java 实现，无需 native 绑定文件，支持 Windows/Linux/macOS。**RXTX**（`org.rxtx:rxtx`）是较老的串口库，需要对应平台的 DLL/SO 文件，nms4pos 保留它是为了兼容某些老旧设备。

---

## 二、依赖配置

### 2.1 Maven 依赖（jSerialComm）

**pos1starter**（`nms4cloud-pos1starter/pom.xml`）：

```xml
<dependency>
    <groupId>com.fazecast</groupId>
    <artifactId>jSerialComm</artifactId>
    <version>2.10.2</version>
</dependency>
```

**pos2plugin-biz**（`nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/pom.xml`）：

```xml
<dependency>
    <groupId>com.fazecast</groupId>
    <artifactId>jSerialComm</artifactId>
    <version>2.11.0</version>
</dependency>
```

**pos6monitor**（`nms4cloud-pos6monitor/pom.xml`）：

```xml
<dependency>
    <groupId>com.fazecast</groupId>
    <artifactId>jSerialComm</artifactId>
    <version>2.11.0</version>
</dependency>
```

### 2.2 本地 JAR 依赖（RXTX + jna-platform）

`pos2plugin-biz/lib/` 和 `pos6monitor/lib/` 目录下存放以下文件，通过 `<systemPath>` 引用：

```xml
<!-- pos2plugin-biz/pom.xml -->
<dependency>
    <groupId>org.rxtx</groupId>
    <artifactId>rxtx</artifactId>
    <version>2.1.7</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/lib/RXTXcomm.jar</systemPath>
</dependency>
<dependency>
    <groupId>net.java.dev.jna</groupId>
    <artifactId>jna-platform</artifactId>
    <version>5.17.0</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/lib/jna-platform-5.17.0.jar</systemPath>
</dependency>
```

> **注意**：`pos6monitor` 是独立 Spring Boot 项目（parent 为 `spring-boot-starter-parent 3.4.1`），通过 `includeSystemScope=true` 确保 system scope 依赖被打包进 JAR。

---

## 三、核心实现（PortHandler.java）

核心逻辑集中在 `PortHandler.java`（`pos2plugin-biz`）：

```
pos2plugin-biz/src/main/java/com/lemontree/framework/print/jobHandlers/PortHandler.java
```

该文件约 1913 行，处理所有串口/网络打印机的打开、写入、状态查询。

### 3.1 串口初始化

```java
import com.fazecast.jSerialComm.SerialPort;
import com.fazecast.jSerialComm.SerialPortDataListener;
import com.fazecast.jSerialComm.SerialPortEvent;

// 获取可用串口列表（自动扫描）
SerialPort[] commPorts = SerialPort.getCommPorts();

// 选择指定端口
SerialPort comPort = SerialPort.getCommPorts()[0];
for (SerialPort port : commPorts) {
    if (port.getSystemPortName().equals(comName)) {
        comPort = port;
        break;
    }
}

// 打开端口
if (!comPort.openPort()) {
    log.error("打开串口失败: {}", comName);
    return false;
}

// 配置波特率（热敏打印机常用 9600 / 115200）
comPort.setBaudRate(115200);
comPort.setNumDataBits(8él
comPort.setParity(SerialPort.NO_PARITY);
comPort.setNumStopBits(SerialPort.ONE_STOP_BIT);

// 设置超时（毫秒）
comPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 0, 0);
```

### 3.2 写入 ESC/POS 指令

```java
// 获取输出流，写入字节数据
OutputStream out = comPort.getOutputStream();

// ESC/POS 打印机指令常量（PortHandler.java 中定义）
private static final byte ESC = 0x1B;  // Escape
private static final byte GS  = 0x1D;  // Group Separator
private static final byte FS  = 0x1C;  // File Separator
private static final byte DLE = 0x10;  // Data Link Escape
private static final byte EOT = 0x04;  // End of Transmission

// 初始化打印机
out.write(new byte[]{ESC, '@'});

// 设置居中对齐
out.write(new byte[]{ESC, 'a', 0x01});

// 放大字体（2倍高宽）
out.write(new byte[]{GS, '!', 0x11});

// 切纸
out.write(new byte[]{GS, 'V', 0x01});

// 刷出缓冲区
out.flush();
```

### 3.3 打印机状态查询（DLE EOT）

热敏打印机支持通过 `DLE EOT` 命令查询状态：

```java
// 查询打印机状态（1 = 实时状态）
byte[] statusCmd = new byte[]{DLE, EOT, 0x01};
out.write(statusCmd);

// 读取状态响应（通过输入流）
SerialPortDataListener listener = new SerialPortDataListener() {
    @Override
    public int getListeningEvents() {
        return SerialPort.LISTENING_EVENT_DATA_AVAILABLE;
    }

    @Override
    public void serialEvent(SerialPortEvent event) {
        if (event.getEventType() == SerialPort.LISTENING_EVENT_DATA_AVAILABLE) {
            byte[] buffer = new byte[256];
            int numRead = comPort.getInputStream().read(buffer);
            // buffer[0] 即为状态字节：
            // bit0 = 打印机缺纸
            // bit1 = 打印机忙碌
            // bit2 = 钱箱接口_pin为高
            // bit3 = 错误状态
        }
    }
};
comPort.addDataListener(listener);
```

### 3.4 网络打印机（TCP Socket）

部分打印机支持网络打印（TCP 9100 端口），通过标准 `Socket` 实现：

```java
import java.net.Socket;
import java.io.OutputStream;

// 连接网络打印机（IP + Port 9100）
Socket socket = new Socket(printerIp, 9100);
OutputStream out = socket.getOutputStream();

// 写入打印数据
out.write(printData);
out.flush();

// 关闭连接
out.close();
socket.close();
```

---

## 四、支持的打印机品牌

PortHandler.java 支持多种品牌，通过品牌常量定义不同的初始化指令：

| 常量 | 品牌型号 | 说明 |
|------|---------|------|
| `EPSON_T_T81` | Epson TM-T81 | 经典热敏小票机 |
| `STAR_SP700` | Star SP700 | 针式打印机（厨房打印） |
| `XP_58X` | 新北洋 XP-58X | 58mm 热敏 |
| `XP_80X` | 新北洋 XP-80X | 80mm 热敏 |
| `北洋 BTP_98NP` | 北洋 BTP-98NP | 票据打印机 |
| 网络打印机 | TCP 9100 | 支持任意品牌网络打印机 |

每种品牌的初始化序列、对齐方式、切纸指令均有差异，PortHandler 中通过工厂模式根据品牌类型选择对应实现。

---

## 五、典型打印流程

```
1. 接收打印任务（订单数据）
       ↓
2. 根据配置选择打印机（串口 / 网络）
       ↓
3. 打开串口 / 建立 Socket 连接
       ↓
4. 发送 ESC/POS 初始化序列
       ↓
5. 写入打印内容（店名/订单号/菜品/金额/二维码）
       ↓
6. 查询打印机状态（DLE EOT）
       ↓
7. 发送切纸指令（GS V）
       ↓
8. 关闭连接，释放资源
```

---

## 六、RXTX 遗留兼容

RXTX 通过 `gnu.io.SerialPort` API 使用，jSerialComm 通过 `com.fazecast.jSerialComm.SerialPort` 使用。两者 API 不兼容，PortHandler 中通过 `CommPortIdentifier`（RXTX）选择老设备：

```java
// RXTX 方式（老设备兼容）
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;

CommPortIdentifier portId = CommPortIdentifier.getPortIdentifier("COM3");
SerialPort serialPort = (SerialPort) portId.open("PrintJob", 2000);
serialPort.setSerialPortParams(9600, SerialPort.DATABITS_8,
    SerialPort.STOPBITS_1, SerialPort.PARITY_NONE);
```

---

## 七、注意事项与风险

### 7.1 风险点

1. **两套串口库并存**：同时加载可能产生端口冲突，建议调试时确认是哪个库在占用端口
2. **system scope 依赖**：RXTX 和 jna-platform 以 system scope 引入，CI/CD 构建时必须确保 `lib/` 目录被正确提交
3. **pos6monitor 独立打包**：`includeSystemScope=true` 会将这些本地 JAR 打入最终镜像，增加镜像体积
4. **端口占用**：Windows 上串口占用后不释放可能导致下次打开失败，建议使用完毕后显式关闭

### 7.2 建议

- **逐步废弃 RXTX**：新设备统一使用 jSerialComm 2.11.0，移除 RXTX 依赖
- **统一波特率配置**：不同品牌打印机默认波特率不同，建议在配置中心统一管理
- **状态重试机制**：打印机忙时（热敏头加热中）应加入重试逻辑

---

## 八、相关文档

- [POS端组件全景图](./POS端组件全景图.md)
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)
