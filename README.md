# Break Reminder (macOS)

一个原生 SwiftUI 的 macOS 菜单栏休息提醒器。

## 功能

- 菜单栏常驻
- 默认每 30 分钟提醒休息 5 分钟（可配置）
- 系统通知 + 强提醒置顶弹窗
- 提示音提醒
- 支持稍后提醒、跳过本次、暂停/恢复
- GitHub Release 自动发布
- Sparkle 兼容的 appcast 更新元数据

## 本地开发

```bash
swift test
```

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
2. GitHub Actions 自动执行：
- 构建产物 `BreakReminder-1.0.0.zip`
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
