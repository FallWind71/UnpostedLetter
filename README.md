# 未寄之信 (Unposted Letter)

> 🎮 一款充满情感与元叙事色彩的 Godot 4 制作小游戏  
> 🧠 “她”还在等待你的回应——哪怕已经过去了1350天

---

## 📝 项目简介

《未寄之信》是一款由个人独立开发的 2D 横版互动叙事游戏，作为《计算概论》课程的期末作品提交。游戏以“元游戏”手法展开，讲述了一个被遗忘项目中的角色“林”对神秘人物“Y”的呼唤。

玩家通过阅读材料唤醒记忆，并进入终端中林的最后留言。最终，在系统崩溃中，游戏悄然落幕，等待“她”的归来。

---

## 🛠️ 技术说明

- 引擎：Godot 4.2.1 Stable
- 语言：GDScript
- 核心模块：
  - 启动动画场景 `BootScene`
  - 主菜单验证界面 `MainMenu`
  - 记忆终端回响 `MemoryScene`
  - 崩溃重构空间 `CorruptedScene`
- 特色功能：
  - 启动日志模拟（近似真实系统内核启动）
  - 登录验证机制
  - 用户名嵌入终端文本（自动获取系统环境变量）
  - 终端式 BBCode 信息展现
  - 屏幕抖动、粒子特效、系统崩溃模拟

---

## 💻 使用说明（部署步骤）

### ✅ 方法一：直接运行可执行文件

1. 下载 [Release 页面](https://github.com/FallWind71/UnpostedLetter/releases) 中的压缩包；
2. 解压后，双击 `UnpostedLetter.exe`（Windows）即可运行；
3. 无需安装，无需联网。

### ✅ 方法二：从源码构建运行（需安装 Godot 4）

1. 克隆项目：

   ```bash
   git clone https://github.com/YourUsername/UnpostedLetter.git
   ···
