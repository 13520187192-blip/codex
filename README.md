# Break Reminder (macOS)

一个休息提醒器仓库，包含：
- `BreakReminderApp`：macOS 原生 SwiftUI 菜单栏应用（可弹出设置窗口）
- `BreakReminderWindows`：Windows 托盘应用（WinForms）

## 功能

- 菜单栏常驻
- 默认每 30 分钟提醒休息 5 分钟（可配置，范围 1~60 分钟）
- 系统通知 + 强提醒置顶弹窗
- 多种提示音可选，支持音量调节和试听
- 支持稍后提醒、跳过本次、暂停/恢复
- GitHub Release 自动发布
- Sparkle 兼容的 appcast 更新元数据

## 本地开发

```bash
swift test
```

Windows（在 Windows 机器）：

```powershell
dotnet build BreakReminderWindows/BreakReminderWindows.csproj -c Release
```

## macOS 使用

1. 启动后应用常驻在菜单栏（时钟图标）。
2. 点击菜单栏图标可直接开始/暂停/稍后提醒/跳过本次。
3. 点击“打开设置”会弹出独立设置窗口。
4. 关闭设置窗口后应用不会退出，仍在菜单栏继续提醒。

## 设计资源替换（给设计师）

设计师只需要修改这个目录：`BreakReminderApp/DesignAssets/`

- `hero.png`
- `bg_pattern.png`
- `icon_clock.png`
- `font_title.ttf`
- `font_body.ttf`

规则：

1. 文件名必须保持不变。
2. 后缀必须保持不变。
3. 设计师改完后，直接把整个 `DesignAssets` 文件夹回传。
4. 程序会自动加载新素材；缺失素材时自动回退默认样式。

给设计师的标准说明与可复制提示词：

- `BreakReminderApp/DesignAssets/AI_DESIGN_HANDOFF_ZH.md`
- `BreakReminderApp/DesignAssets/COPY_TO_DESIGN_AI.txt`
- `BreakReminderApp/DesignAssets/UI_MODULE_MAP_FOR_DESIGN_ZH.md`
- `BreakReminderApp/DesignAssets/COPY_THIS_TO_UI_AI_ZH.txt`

## 与 GitHub 同步

```bash
git init
git branch -M main
git add .
git commit -m "feat: initial break reminder app"
git remote add origin git@github.com:<your-user>/break-reminder-macos.git
git push -u origin main
```

## 发布流程

1. 创建并推送版本标签：`v1.0.0`
2. GitHub Actions 自动执行（macOS + Windows）：
- 构建产物 `BreakReminder-1.0.0.zip`
- 构建产物 `BreakReminder-1.0.0.dmg`
- 构建产物 `BreakReminderWindows-1.0.0-win-x64.zip`
- 生成 `appcast.xml`
- 发布 GitHub Release
- 同步 `dist/` 到 `gh-pages`

## 自动更新说明

- `UpdaterController` 已预留 Sparkle 2 接入。
- 当工程链接 Sparkle 后，应用内“立即检查更新”将走 Sparkle。
- 未链接 Sparkle 时，按钮会打开 GitHub Releases 页面。
- 在 `BreakReminder.xcodeproj` 里已写入占位的 `SUFeedURL` 与 `SUPublicEDKey`，发布前请替换成真实值。

## 权限

首次运行需要允许通知权限，未签名版本在 macOS 下可能出现安全提示。

如果 macOS 提示“文件已损坏/无法验证开发者”，请在终端执行：

```bash
xattr -dr com.apple.quarantine /Applications/BreakReminder.app
```

如果看不到主窗口，这是正常现象：默认是菜单栏应用，请点击右上角菜单栏时钟图标打开设置窗口。
