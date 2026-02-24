# Jenkins 凭据设置指南

## 概述

本文档介绍如何在 Jenkins 中添加harbor的访问凭据, 用于构建产物推送到Harbor仓库。

---

## 二、在 Jenkins 中添加凭据

### 1. 进入凭据管理页面

1. 访问 Jenkins：`http://<节点IP>:30080`
2. 点击左侧菜单 **Manage Jenkins**（系统管理）
3. 点击 **Manage Credentials**（凭据管理）
4. 点击 **(global)** 域
5. 点击左侧 **Add Credentials**（添加凭据）

### 2. 配置凭据信息

#### 使用个人访问令牌（推荐）

```
Kind: Username with password
Scope: Global
Username: admin
Password: Harbor12345
ID: harbor-user-auth
Description: nexus


```
