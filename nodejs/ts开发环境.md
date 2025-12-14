<div id="chap-install"></div>

[⬆️ 返回目录](#catalog)


## 开发环境


在 Windows 上使用 VS Code 进行 TypeScript (TS) 开发，环境配置其实非常标准且简单。因为 VS Code 本身就是用 TypeScript 写的，所以它对 TS 的支持是“亲儿子”级别的。

以下是从**安装**到**起飞**的完整清单：

---

### 第一步：基础环境（必装）

VS Code 本身只是一编辑器，它不懂怎么运行代码，必须依赖 Node.js 环境。

1.  **安装 Node.js**
    *   **作用**：提供运行环境，以及包管理器 `npm`（用来下载 TS 编译器）。
    *   **操作**：去 [Node.js 官网](https://nodejs.org/) 下载 **LTS 版本**（长期支持版），一路“下一步”安装即可。
    *   **验证**：打开 CMD 或 PowerShell，输入 `node -v` 和 `npm -v`，有版本号即成功。

2.  **安装 TypeScript 编译器 (tsc)**
    *   **作用**：把 TS 代码翻译成 JS 代码。
    *   **操作**：在终端运行全局安装命令：
        ```powershell
        npm install -g typescript
        ```
    *   **验证**：输入 `tsc -v`，看到版本号即成功。

3.  **安装 ts-node (开发神器)**
    *   **作用**：**这是必须的！** 它让你不用每次都手动“编译再运行”，而是直接在内存中编译并运行 TS 代码。
    *   **操作**：
        ```powershell
        npm install -g ts-node
        ```

---

### 第二步：VS Code 核心插件（推荐）

VS Code 自带 TS 语法高亮和智能提示，**不需要**安装专门的 TS 语言插件。但为了写出高质量代码，以下插件强烈建议安装：

1.  **ESLint**
    *   **必须**。用于检查代码规范，发现低级错误。
2.  **Prettier - Code formatter**
    *   **必须**。一键格式化代码，治愈强迫症（自动加分号、统一单引号等）。
3.  **Error Lens** (可选，强烈推荐)
    *   它会把报错信息直接**显示在代码行尾**，不用鼠标悬停去看错误原因，开发效率提升神器。
4.  **JavaScript and TypeScript Nightly** (可选)
    *   如果你想体验 TS 最新版本的特性，可以装这个（通常用 VS Code 内置的就够了）。

---

### 第三步：Windows 专属坑点（PowerShell 权限）

这是 Windows 用户**100% 会遇到**的问题。
当你第一次在 VS Code 的终端里运行 `tsc` 或 `ts-node` 时，可能会报错：
> “因为在此系统上禁止运行脚本...”

**解决方法**：
1.  以**管理员身份**打开 PowerShell。
2.  输入命令：
    ```powershell
    Set-ExecutionPolicy RemoteSigned
    ```
3.  输入 `A` 或 `Y` 确认。

---

### 第四步：如何开始一个 TS 项目（标准流程）

不要只建一个 `.ts` 文件就开写，那是“脚本模式”。标准的“工程模式”是这样的：

1.  **新建文件夹**，用 VS Code 打开。
2.  **初始化 npm**：
    在终端运行：`npm init -y` (生成 `package.json`)。
3.  **初始化 TypeScript 配置**：
    在终端运行：`tsc --init`
    *   这一步会生成 **`tsconfig.json`**。
    *   **重要**：这个文件是 TS 项目的灵魂。它告诉编译器“你要多严格？”、“代码编译到哪里？”。
4.  **编写代码**：
    新建 `index.ts`，写点东西：
    ```typescript
    const msg: string = "Hello Windows";
    console.log(msg);
    ```
5.  **运行代码**：
    *   **方式 A (开发用)**：直接运行 `ts-node index.ts` (极快)。
    *   **方式 B (构建用)**：运行 `tsc`，你会发现多了一个 `index.js`，然后运行 `node index.js`。

---

### 第五步：进阶调试 (Debugging)

VS Code 的调试功能非常强大，不需要 `console.log` 也能调试 TS。

1.  点击左侧边栏的“运行和调试”图标（虫子图标）。
2.  点击 "create a launch.json file"。
3.  选择 **Node.js**。
4.  VS Code 会自动识别你的 TS 环境。你可以在代码左侧打断点，直接按 **F5** 就能进入调试模式，查看变量值。

---

### 总结清单

你需要准备的只有这 4 样东西：

1.  **软件**：VS Code + Node.js (LTS)。
2.  **全局工具**：`npm i -g typescript ts-node`。
3.  **插件**：ESLint + Prettier。
4.  **权限**：PowerShell 执行策略 (`Set-ExecutionPolicy RemoteSigned`)。

搞定这些，你就可以开始写 NestJS 或 Vue + TS 了。

这两个命令是 TypeScript 项目的**两大基石**。

简单来说：**Node.js 不认识 TypeScript，浏览器也不认识 TypeScript。**

为了让代码能跑起来，你需要把 TS “翻译”成 JS。这两个命令，就是为你搭建这个**“翻译工厂”**的。

我们把写代码比作**开公司**，来看看这两个命令是干什么的：

---

### 1. `npm init -y`：领取营业执照
*   **产物**：`package.json`
*   **角色**：公司的**营业执照 + 员工名单**。

**为什么要它？**
写 TS 脚本，你首先需要下载 TypeScript 这个工具（编译器）。
*   TypeScript 不是电脑自带的，也不是 Node.js 自带的。
*   你需要运行 `npm install typescript` 来安装它。
*   **`package.json` 负责记录你安装了什么工具**。如果没有这个文件，你的项目就是“黑户”，没办法管理安装的依赖（比如 TypeScript、ts-node、types/node）。
*   **`-y` 的意思**：Yes。表示“全部默认通过”，不要问我项目叫什么、作者是谁，直接给我生成一张默认的执照，节省时间。

---

### 2. `tsc --init`：制定加工手册
*   **产物**：`tsconfig.json`
*   **角色**：工厂的**操作说明书**。

**为什么要它？**
你安装好了 TypeScript 编译器（有了工人），但工人不知道该怎么干活。
因为 TS 转 JS 有一万种转法，你需要通过这个文件告诉编译器：
*   **目标是谁？** 是转成古老的 ES5（为了兼容 IE 浏览器），还是最新的 ESNext（给 Node.js 跑）？
*   **有多严格？** 是允许你随便写（`noImplicitAny: false`），还是必须严谨（`strict: true`）？
*   **代码在哪？** 源码在 `src` 还是根目录？输出到 `dist` 还是原地生成？

如果你不执行这个命令，编译器就会用**默认配置**，通常这个默认配置非常难用（比如不会把文件输出到指定目录，或者检查太松），导致你的项目乱糟糟的。

---

### 总结：它们的关系

| 命令 | 生成文件 | 作用 | 也就是... |
| :--- | :--- | :--- | :--- |
| **`npm init -y`** | `package.json` | 这里的项目叫什么？需要用到哪些工具（如 TS）？ | **身份ID + 工具箱** |
| **`tsc --init`** | `tsconfig.json` | 这些工具具体该怎么干活？编译规则是什么？ | **施工图纸** |

**写 TS 脚本的标准流程：**
1.  `npm init -y` (先建档，准备招人)
2.  `npm i -D typescript` (招募 TS 编译器这个工人)
3.  `tsc --init` (给工人发图纸，告诉他怎么干)
4.  开始写代码。

缺了任何一个，你的 TS 开发体验都会寸步难行。

这是一个非常敏锐的观察！你发现了 Node.js 开发中初学者最容易产生误解的一个点：**全局安装 vs 本地安装**。

你说的“无法直接执行 `tsc`”是**事实**，但“所以 `npm init` 不需要”这个结论是**错误**的。

恰恰相反，**正是因为本地安装无法直接执行 `tsc`，才更需要 `npm init` 生成的 `package.json` 来帮我们执行它。**

让我为你解开这个死结：

---

### 1. 为什么你输入 `tsc` 会报错？

当你运行 `npm install typescript`（不带 `-g`）时，发生的是**本地安装**：

1.  TypeScript 被下载到了当前目录的 `node_modules` 文件夹里。
2.  它的可执行文件（`tsc.exe`）被藏在了 **`./node_modules/.bin/tsc`** 这里。

但是，你的 Windows 命令行（CMD/PowerShell）根本不知道这个目录的存在。当你输入 `tsc` 时，它只去系统环境变量（Path）里找。找不到，自然报错。

**那怎么办？有两种方法调用这个“隐藏”的 tsc，而这两种方法都证明了 `package.json` 的重要性。**

---

### 2. 只有 `npm init` 了，才能用“快捷键”运行 tsc

这是专业开发中最标准的做法。

如果你运行了 `npm init -y` 生成了 `package.json`，你就可以在里面配置一个“快捷指令”：

**package.json:**
```json
{
  "scripts": {
    // npm run 会自动把 ./node_modules/.bin 加入到临时环境变量中！
    "build": "tsc" 
  }
}
```

现在，你只需要在终端输入：
```bash
npm run build
```
神奇的事情发生了：**npm 知道去哪找那个隐藏的 `tsc`，代码成功编译了。**

**结论**：如果没有 `npm init` 生成的 `package.json`，你就没法配置这个 `scripts`，每次运行代码都会很麻烦。

---

### 3. 如果不 `npm init`，后果是什么？

假设你真的跳过 `npm init`，直接 `npm install typescript`，你的项目会变成这样：

1.  **无法复现**：
    你把代码发给同事，或者换台电脑。由于没有 `package.json` 记录你用了哪个版本的 TypeScript，同事必须瞎猜安装哪个版本。如果你的项目需要 TS 5.0，他装了 4.0，项目直接跑不起来。
2.  **无法 Git 管理**：
    通常我们会忽略庞大的 `node_modules`。如果没有 `package.json` 记录依赖，你删了 `node_modules` 后，就再也找不回原来的环境了。
3.  **运行极其麻烦**：
    没有 `scripts`，你每次编译都要手动输入这一长串：
    ```bash
    .\node_modules\.bin\tsc
    # 或者用 npx
    npx tsc
    ```

---

### 4. 总结：正确的姿势

不要因为“本地安装敲命令报错”就觉得它没用，也不要去依赖“全局安装”（`npm i -g typescript`），因为全局安装会导致不同项目版本冲突。

**标准流程永远是：**

1.  **`npm init -y`** (必须！为了拥有 `package.json` 来管理依赖和脚本)
2.  **`npm install -D typescript`** (安装到本地)
3.  **配置 `package.json`**：
    ```json
    "scripts": {
      "dev": "ts-node src/index.ts",
      "build": "tsc"
    }
    ```
4.  **运行**：`npm run dev` 或 `npm run build`。

**一句话：`npm init` 实际上是为了让你更方便地调用那个“原本无法直接执行”的 `tsc`。**

npm 识别“根目录”的逻辑非常简单且暴力，核心规则只有一条：

**寻找最近的 `package.json` 文件。**

npm 使用的是一种 **“向上冒泡（Bubble Up）”** 或 **“递归向上查找”** 的算法。无论你在终端当前的目录是多深，npm 都会一层一层往上找，直到找到 `package.json` 或者抵达磁盘根目录为止。

以下是具体的运作流程图解：

---

### 1. 查找算法演示

假设你的项目结构是这样的，而你的终端（Terminal）目前停留在最深层的 `utils` 文件夹里：

```text
C:\Users\Dev\MyProject  <---- 真正的项目根目录 (含有 package.json)
      │
      └── src
           │
           └── services
                 │
                 └── utils  <---- 🔴 你在这里输入了 npm install
```

当你输入 `npm install` 或 `npm run xxx` 时，npm 的心理活动如下：

1.  **第一步**：检查当前目录 `C:\Users\Dev\MyProject\src\services\utils`。
    *   *“这里有 package.json 吗？”* -> **没有**。
2.  **第二步**：退回上一级 `C:\Users\Dev\MyProject\src\services`。
    *   *“这里有 package.json 吗？”* -> **没有**。
3.  **第三步**：退回上一级 `C:\Users\Dev\MyProject\src`。
    *   *“这里有 package.json 吗？”* -> **没有**。
4.  **第四步**：退回上一级 `C:\Users\Dev\MyProject`。
    *   *“这里有 package.json 吗？”* -> **找到了！🎉**

**结果**：
npm 认定 `C:\Users\Dev\MyProject` 就是**根目录**。
它会把包安装到 `C:\Users\Dev\MyProject\node_modules`，并修改 `C:\Users\Dev\MyProject\package.json`。

---

### 2. 找不到会怎样？

如果 npm 一直往上找，直到到达磁盘的根目录（比如 Windows 的 `C:\` 或 Mac/Linux 的 `/`）都还没找到 `package.json`，它通常会报错：

> `npm ERR! enoent ENOENT: no such file or directory, open 'C:\package.json'`

或者提示你没有 `package.json`，会创建一个 `node_modules` 锁文件等警告。

这就是为什么有时候你在一个空文件夹里（没有运行 `npm init`）运行 `npm install xxx`，npm 会警告你没有描述文件，或者有时候它会一直往上找，结果把包安装到了你的**用户主目录**（如果你主目录下恰好有个 package.json）—— **这是一个常见的误操作坑。**

---

### 3. 如何验证 npm 认为哪里是根目录？

你可以使用一个简单的命令来查看 npm 当前认定的“安装位置”在哪里：

```bash
npm root
```

*   如果你在项目深层目录运行这个命令，它会打印出绝对路径，指向该项目根目录下的 `node_modules`。
*   例如：`C:\Users\Dev\MyProject\node_modules`

---

### 4. 特殊情况：Monorepo (工作空间)

如果你的项目是一个 Monorepo（一个大仓库里套着好几个小项目），结构可能长这样：

```text
/MyRepo (含 package.json)
  └── packages
       └── server (含 package.json) <---- 🔴 你在这里
```

*   如果你在 `server` 目录运行 npm，它首先发现 `server` 目录下就有 `package.json`，所以它会**立即停止**，把 `server` 目录当作当前的根目录。
*   它不会继续往上找外层的 `MyRepo` 了（除非你使用了特定的 workspace 命令）。

### 总结

npm 识别根目录不靠“猜”，也不靠 `.git` 文件夹，**全靠寻找离你最近的那个 `package.json`**。

这就是为什么 `npm init -y` 是项目的第一步——它像插旗占地一样，告诉 npm：“**到此为止，这就是我的地盘（根目录）。**”


`npm run`（全称 `npm run-script`）的底层逻辑非常精妙，它主要解决了一个核心痛点：**“如何方便地执行本地安装的工具”**。

它的工作原理可以总结为：**“临时环境变量注入” + “Shell 执行”**。

下面为你拆解它执行时的 **4 个关键步骤**：

---

### 1. 寻找这一层的“军火库” (`node_modules/.bin`)

当你运行 `npm run build`（假设 `build` 对应的是 `tsc`）时，npm 做的第一件事不是去系统的环境变量里找 `tsc`，而是**先看自家后院**。

*   **npm 的操作**：
    它会自动找到当前项目根目录下的 **`node_modules/.bin`** 文件夹。
*   **里面有什么？**
    如果你安装了 `typescript`，这个文件夹里就会有一个名为 `tsc` (或 `tsc.cmd` / `tsc.ps1`) 的文件。这其实是一个**软链接（快捷方式）**或**脚本**，指向了 `node_modules/typescript/bin/tsc` 真正的源码位置。

### 2. 施展魔法：临时修改环境变量 (The Magic PATH)

这是 `npm run` 最核心的逻辑，也是为什么你能直接运行 `tsc` 的原因。

在执行命令**之前**，npm 会悄悄修改当前的 **PATH 环境变量**。

*   **正常终端的 PATH**：
    `C:\Windows\system32; C:\Program Files\nodejs; ...` (只有系统层面的工具)
*   **npm run 运行时的 PATH**：
    **`.\node_modules\.bin;`** `C:\Windows\system32; ...`

**重点来了**：npm 把 `node_modules/.bin` 加到了 **PATH 的最前面**！

这意味着，当脚本里写了 `tsc` 时，系统会**优先**在这个目录里找到了本地安装的 `tsc`，而忽略掉你电脑上可能安装的任何全局 `tsc`。

> **这就是为什么不同项目可以使用不同版本的 TypeScript 而互不干扰的原因。**

### 3. 召唤 Shell (外包执行)

修改好环境变量后，npm 本身并不直接执行命令，它是把命令**“外包”**给系统的 Shell 去执行。

*   **在 Windows 上**：它会启动 `cmd.exe` (或者 PowerShell)。
*   **在 Mac/Linux 上**：它会启动 `/bin/sh`。

npm 会把 `package.json` 里写的命令字符串（比如 `"tsc && echo done"`）原封不动地丢给 Shell。

**这就解释了为什么：**
*   你可以在 `scripts` 里使用 `&&` (串行)、`&` (并行)、`|` (管道) 等符号，因为这些是 Shell 的语法，npm 只是负责传话的。
*   如果你在 Windows 上写 `rm -rf` 可能会报错，因为 Windows 的 `cmd` 不认识这个命令（除非你装了 git bash 等环境）。

### 4. 生命周期钩子 (Lifecycle Hooks)

在执行命令前后，npm 还会多看一眼 `scripts` 里有没有**“保镖”**。

如果你运行 `npm run build`，npm 会按顺序查找并执行：
1.  **`prebuild`**：如果存在，先执行它。
2.  **`build`**：执行本体。
3.  **`postbuild`**：如果存在，最后执行它。

这对于自动化构建非常有用（比如：先删除 dist 目录 -> 再编译 -> 最后复制资源）。

---

### 总结：npm run 的完整执行流

当你输入 `npm run build` (对应 `tsc`)：

1.  **读取**：npm 读取 `package.json`，找到 `"build": "tsc"`。
2.  **配路**：npm 把 `./node_modules/.bin` 加入到 `PATH` 变量的最开头。
3.  **执行**：npm 唤起 `cmd.exe` (Windows) 或 `sh` (Linux)，告诉它：“在新的 PATH 环境下，帮我执行 `tsc`”。
4.  **查找**：`cmd` 在 `.bin` 目录里发现了 `tsc`，于是执行它。
5.  **复原**：命令执行完毕，npm 关闭 Shell，环境变量恢复原状（不会污染你的系统）。

**一句话总结：`npm run` 就是一个帮你把“本地工具目录”临时加到“系统路径”里的快捷执行器。**


定义这 3 个脚本非常简单，完全不需要任何特殊的配置。你只需要在 `package.json` 的 `"scripts"` 字段里，按照 **“前缀 + 脚本名”** 的命名规则来写即可。

npm 的规则是：**只要脚本名匹配 `pre<name>` 和 `post<name>`，它们就会自动绑定到 `<name>` 上。**

---

### 1. 基础写法演示

假设你的主任务叫 `build`。

打开 `package.json`，这样定义：

```json
{
  "scripts": {
    "prebuild": "echo \"准备开始构建...清理旧文件\"",
    "build": "tsc",
    "postbuild": "echo \"构建完成！准备上线\""
  }
}
```

### 2. 如何触发？

你**只需要**运行中间那个主命令：

```bash
npm run build
```

**执行顺序会自动变成：**
1.  npm 发现有 `prebuild`，先执行它（输出“准备开始...”）。
2.  如果不报错，接着执行 `build`（运行 `tsc` 编译）。
3.  如果不报错，最后执行 `postbuild`（输出“构建完成...”）。

---

### 3. 实战场景：NestJS/TS 开发最常用的套路

在真实的 TypeScript 开发中，我们通常利用这三个钩子实现 **“清理 -> 编译 -> 运行”** 的自动化流。

**需求**：
1.  **编译前**：先把旧的 `dist` 文件夹删掉，防止残留垃圾文件。
2.  **编译**：把 TS 转成 JS。
3.  **编译后**：自动尝试运行生成的代码，看看有没有问题。

**配置如下**：

```json
{
  "scripts": {
    // 1. pre: 使用 rimraf (跨平台删除工具) 删除 dist 目录
    "prebuild": "rimraf dist",

    // 2. 本体: 运行 TypeScript 编译器
    "build": "tsc",

    // 3. post: 编译完顺便运行一下，或者复制一些非代码文件(图片/配置)到 dist
    "postbuild": "echo Build success! Starting app... && node dist/index.js"
  },
  "devDependencies": {
    "rimraf": "^5.0.0", // 记得 npm i -D rimraf，否则 windows 上删文件很麻烦
    "typescript": "^5.0.0"
  }
}
```

当你输入 `npm run build` 时，它就会像流水线工人一样帮你把这一套全干完。

---

### 4. 两个必须注意的规则

#### 规则一：名字必须严格匹配
钩子是跟着脚本名走的。
*   如果你的主脚本叫 `"compile": "tsc"`。
*   那你的钩子必须叫 `"precompile"` 和 `"postcompile"`。
*   写成 `"prebuild"` 是不会被触发的。

#### 规则二：一旦报错，立即终止 (熔断机制)
这是 npm 最棒的设计之一。
*   如果 **`prebuild`** 执行失败了（比如删除文件权限不足，或者脚本里抛出了 Error，退出码非 0）。
*   那么 **`build`** 和 **`postbuild`** **绝对不会执行**。

这起到了保护作用：如果“清理战场”都失败了，就不要强行“开始施工”了。

### 总结

*   **定义**：在 `scripts` 里写 `pre<name>`, `<name>`, `post<name>`。
*   **运行**：只运行 `npm run <name>`。
*   **作用**：用来串联工作流，比如 **“清理环境、准备数据” (pre)** 和 **“部署上线、发送通知” (post)**。



* **launch.json文件**
```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Edge",
            "request": "launch",
            "type": "msedge",
            "url": "http://localhost:8080",
            "webRoot": "${workspaceFolder}"
        },
        {
            "type": "node",
            "request": "launch",
            "name": "Launch Program",
            "skipFiles": [
                "<node_internals>/**"
            ],
            "program": "${workspaceFolder}\\src\\index.ts",
            "outFiles": [
                "${workspaceFolder}/**/*.js"
            ]
        }
    ]
}
```
* **package.json文件**
```json
{
  "name": "myproject",
  "version": "1.0.0",
  "description": "开发ts",
  "license": "ISC",
  "author": "",
  "type": "commonjs",
  "main": "index.js",
  "scripts": {
    "prebuild": "rmdir /s /q dist",
    "build": "tsc",
    "test": "echo \"Error: no test specified\" && exit 1",
    "debug:path": "echo %PATH%"
  },
  "dependencies": {
    "typescript": "^5.9.3"
  }
}

```

* **tsconfig.json文件**
```json
{
  // Visit https://aka.ms/tsconfig to read more about this file
  "compilerOptions": {
    // File Layout
    "rootDir": "./src",
    "outDir": "./dist",

    // Environment Settings
    // See also https://aka.ms/tsconfig/module
    "module": "nodenext",
    "target": "esnext",
    "types": [],
    // For nodejs:
    // "lib": ["esnext"],
    // "types": ["node"],
    // and npm install -D @types/node

    // Other Outputs
    "sourceMap": true,
    "declaration": true,
    "declarationMap": true,

    // Stricter Typechecking Options
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,

    // Style Options
    // "noImplicitReturns": true,
    // "noImplicitOverride": true,
    // "noUnusedLocals": true,
    // "noUnusedParameters": true,
    // "noFallthroughCasesInSwitch": true,
    // "noPropertyAccessFromIndexSignature": true,

    // Recommended Options
    "strict": true,
    "jsx": "react-jsx",
    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "noUncheckedSideEffectImports": true,
    "moduleDetection": "force",
    "skipLibCheck": true,
  }
}

```


<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-install)