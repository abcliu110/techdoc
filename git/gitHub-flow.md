<div id="chap-gitHub-flow"></div>

[⬆️ 返回目录](#catalog)


## gitHub-flow

如果说 **Git Flow** 是一套严谨的“重装铠甲”，适合传统的软件发布（一个月发一个版）；那么 **GitHub Flow** 就是一件轻便的“运动衫”，适合互联网时代的**持续部署**（一天发十次版）。

**GitHub Flow 的核心规则只有一条：`master`（或 `main`）分支的代码永远是可以部署到生产环境的。**

我们继续用 **"SuperApp"** 项目为例，但这次假设它是一个**Web 网站**，需要每天不断上线新功能。

---

### 场景设定
*   **当前分支**：只有 `main` (GitHub 默认主分支)。
*   **任务**：你需要把网站首页的“背景颜色”从白色改成蓝色。
*   **角色**：你（开发者）和 你的组长（审核者）。

---

### 第一步：创建分支 (Create a Branch)
**区别点**：GitHub Flow **没有** `develop` 分支。所有的功能分支直接从 `main` 拉出来。

**操作：**
```bash
# 1. 确保本地 main 是最新的
git checkout main
git pull origin main

# 2. 基于 main 创建功能分支 (起名要具有描述性)
git checkout -b change-bg-color
```

---

### 第二步：提交更改 (Add Commits)
你在本地修改代码。

**操作：**
```bash
# 修改了 css 文件...
git add style.css
git commit -m "Change background color to blue"
```

---

### 第三步：打开 Pull Request (Open a PR) —— **核心步骤**
这是 GitHub Flow 的灵魂。你不需要在本地合并代码，而是把分支推送到远程，然后在网页上发起“合并请求”。

**操作（终端）：**
```bash
# 把你的分支推送到 GitHub
git push origin change-bg-color
```

**操作（GitHub 网页端）：**
1.  登录 GitHub 仓库页面。
2.  你会看到一个黄色的提示框：“change-bg-color had recent pushes”。
3.  点击绿色按钮 **"Compare & pull request"**。
4.  写上描述：“为了护眼，把背景改成蓝色”。
5.  点击 **"Create pull request"**。

---

### 第四步：代码审查与讨论 (Discuss and Review)
此时，代码还没有合并到 `main`。PR 页面变成了团队讨论的聊天室。

*   **自动化检查 (CI)**：GitHub Actions 可能会自动运行测试。如果测试挂了，PR 会显示红叉，禁止合并。
*   **人工审查**：你的组长在网页上看到代码，评论说：“蓝色太深了，浅一点。”

**你继续修改（在本地）：**
```bash
# 修改代码...
git add style.css
git commit -m "Lighten the blue color"

# 再次推送 (GitHub 上的 PR 会自动更新，不需要重新建 PR)
git push origin change-bg-color
```

组长再次看网页，满意了，点击了 **"Approve"**。

---

### 第五步：部署与测试 (Deploy)
*注意：在严格的 GitHub Flow 中，这一步通常发生在合并之前。你通常会把这个分支部署到一个测试环境（Staging），验证没问题后再合并。*

但对于大多数简单项目，流程是：**合并即上线**。

---

### 第六步：合并 (Merge)
组长或你自己在 GitHub PR 页面上点击那个大大的绿色按钮：**"Merge pull request"**。

**发生了什么？**
1.  GitHub 自动把 `change-bg-color` 的代码合并到了 `main`。
2.  如果不使用 CI/CD，你需要去服务器上拉取 `main` 的代码。
3.  如果有 CI/CD（持续集成/部署），GitHub 检测到 `main` 发生了变化，会自动触发脚本，把新代码发布到生产服务器。

---

### 第七步：本地同步与清理
现在线上已经是新版本了，你需要清理本地环境。

**操作：**
```bash
# 1. 切回主分支
git checkout main

# 2. 拉取最新的 main (包含了刚才在网页上合并的代码)
git pull origin main

# 3. 删除本地的旧分支
git branch -d change-bg-color
```

---

### 总结：Git Flow vs GitHub Flow

| 特性 | Git Flow (重型) | GitHub Flow (轻型) |
| :--- | :--- | :--- |
| **主分支** | `master` (生产), `develop` (开发) | 只有 `main` |
| **分支来源** | Feature 从 `develop` 出 | Feature 从 `main` 出 |
| **合并去向** | Feature 合回 `develop` | Feature 合回 `main` |
| **发布模式** | 攒够一批功能，发个 Release | 做完一个功能，发一个 PR，直接上线 |
| **核心工具** | 命令行 (`git flow ...`) | 网页端 (Pull Request) |
| **适用场景** | App、桌面软件、企业级软件 | 网站、SaaS服务、开源项目 |

**一句话总结 GitHub Flow 的工作流：**
从 `main` 切分支 -> 提交 -> **推送到 GitHub 开 PR** -> 讨论/测试 -> **网页上点 Merge** -> 自动上线。

<!-- 跳转链接 -->
[⬆️ 返回目录](#catalog)  |  [文章开头 ➡️](#chap-gitHub-flow)