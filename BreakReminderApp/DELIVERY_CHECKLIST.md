# v1.3.1 交付核查清单

## 时间

- 核查日期：2026-02-12

## 代码状态

- `Settings/SettingsView.swift`：已升级为蓝橙黄昏主界面
- `MenuBar/MenuBarController.swift`：已升级菜单栏面板样式
- `Overlay/BreakOverlayPanelController.swift`：已升级红黑 ArtDeco 强提醒弹窗
- `DesignAssets/NeoNoirTheme.swift`：已新增统一主题 token

## 资源状态

- 参考图已就绪：
  - `DesignAssets/reference_style/`：3 张
  - `DesignAssets/reference_bg/`：12 张
- 产出资源已就绪：
  - `DesignAssets/hero.png`
  - `DesignAssets/bg_pattern.png`
  - `DesignAssets/bg_pattern_alt.png`
  - `DesignAssets/icon_clock.png`
  - `DesignAssets/font_title.ttf`（Bebas Neue）
  - `DesignAssets/font_body.ttf`

## 构建与发布

- Xcode 工程名：`BreakReminder.xcodeproj`
- 发布工作流：`.github/workflows/release.yml`
- 产物目标：
  - `BreakReminder-<version>.zip`
  - `BreakReminder-<version>.dmg`

## 快速自检

```bash
cd "/Users/test/Desktop/codex程序/定时休息提醒器"
./build_and_verify.sh
```

## 待确认项（发布后）

- GitHub Release 中同时出现 zip 和 dmg
- macOS 13.5 (22G74) 安装可启动
- 菜单栏、设置窗口、到点弹窗行为正常
