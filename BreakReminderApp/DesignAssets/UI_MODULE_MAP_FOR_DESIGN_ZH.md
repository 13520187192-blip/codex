# UI 模块设计地图（可直接发给设计师/另一个AI）

> 这是 macOS 菜单栏应用，不是网页。没有 `src/styles.css`。
> 样式由 SwiftUI 代码 + `DesignAssets` 资源文件控制。

## 1) 你要设计的模块（按优先级）

### A. 菜单栏快捷面板（最常用）
- 功能：用户每天点开菜单栏图标看到的小面板。
- 代码位置：`BreakReminderApp/MenuBar/MenuBarController.swift`
- 视图名：`MenuBarQuickControlView`

需要设计的内容：
- 面板背景、圆角、边框、阴影
- 按钮视觉（目前你说“边框不明显”）
- 文字层级（状态文字、主按钮、次按钮）
- 行间距、按钮间距

主要文字：
- `当前状态：空闲/已暂停/该休息了/...`
- `开始专注` / `恢复` / `重新开始`
- `暂停`
- `开始休息`
- `稍后提醒`
- `跳过本次`
- `打开设置`
- `立即检查更新`
- `退出`

---

### B. 设置窗口（视觉主场）
- 功能：点击“打开设置”后弹出的大窗口。
- 代码位置：`BreakReminderApp/Settings/SettingsView.swift`
- 视图名：`SettingsWindowView`, `SettingsPanelView`

需要设计的内容：
- 顶部 Header 样式（标题、描述、图标、hero 图）
- 背景渐变和纹理风格
- 表单卡片样式（GroupBox / Section）
- Slider、Toggle、Stepper、Picker 的统一风格
- 底部按钮区（检查更新 / 关闭窗口）

主要文字：
- `休息提醒设置`
- `窗口可关闭，应用会继续在菜单栏运行`
- `提醒参数`
- `时间设置（1~60 分钟）`
- `提醒间隔：xx 分钟`
- `休息时长：xx 分钟`
- `稍后提醒：xx 分钟`
- `提示音`
- `启用提示音`
- `提示音类型`
- `音量`
- `试听提示音`
- `弹窗与通知`
- `系统通知`
- `弹窗提醒`
- `强制弹窗（置顶）`

---

### C. 到点提醒弹窗（关键瞬间）
- 功能：时间到后强提醒。
- 代码位置：`BreakReminderApp/Overlay/BreakOverlayPanelController.swift`
- 视图名：`BreakOverlayView`

需要设计的内容：
- 弹窗卡片层次（背景/阴影/圆角）
- 按钮优先级（开始休息主按钮）
- 弹窗出现动效（缩放+淡入）
- 强制弹窗模式下的视觉可信度

主要文字：
- `该休息了`
- `离开屏幕几分钟，活动一下身体。`
- `开始休息`
- `稍后提醒`
- `跳过本次`

---

## 2) 资源文件在哪里（你要改的文件）
目录：`BreakReminderApp/DesignAssets/`

必须保留同名：
- `hero.png`
- `bg_pattern.png`
- `icon_clock.png`
- `font_title.ttf`
- `font_body.ttf`

说明：
- 图片和字体只要“同名替换”就会被程序自动加载。
- 如果文件无效，程序会自动回退默认样式（不会崩溃）。

## 3) 代码风格控制文件（程序员用）
如果设计师给的是“设计说明而不是成品图”，程序员改这些文件：
- 菜单栏面板：`BreakReminderApp/MenuBar/MenuBarController.swift`
- 设置窗口：`BreakReminderApp/Settings/SettingsView.swift`
- 提醒弹窗：`BreakReminderApp/Overlay/BreakOverlayPanelController.swift`
- 字体/图片加载：`BreakReminderApp/MenuBar/MenuBarController.swift` 中 `DesignAssetLoader`

## 4) 设计返还格式（必须）
请返还：
1. 替换后的 5 个素材文件
2. 一个 `DESIGN_NOTES.md`，写清：
   - 色板（主色、辅色、警示色）
   - 字体使用规则（标题/正文）
   - 动效建议（时长、曲线、触发）
   - 按钮样式（主按钮/次按钮/危险按钮）

最后把整个 `DesignAssets` 文件夹打包回传即可。
