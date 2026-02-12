# DesignAssets 设计资源包（v1.3.1）

本目录用于 BreakReminder macOS 版的视觉资源与设计交接。

## 当前状态

- 设计方向：Neo-Noir Sunset（蓝橙黄昏）
- 强提醒弹窗：红黑 ArtDeco
- 参考图：已放入 15 张（`reference_bg` 12 张 + `reference_style` 3 张）
- 资源图：已根据参考图生成并接入程序

## 关键文件

- `NeoNoirTheme.swift`：统一颜色/圆角/动画 token
- `hero.png`：设置窗口顶部主视觉（由参考图生成）
- `bg_pattern.png`：主背景纹理（由参考图生成）
- `bg_pattern_alt.png`：备用纹理（由参考图生成）
- `icon_clock.png`：时钟语义图标（重绘）
- `font_title.ttf`：标题字体（Bebas Neue）
- `font_body.ttf`：正文字体（Inter）

## 参考图目录

- `reference_style/`
  - `style_ref_01_gia.jpg`
  - `style_ref_02_neon.jpg`
  - `style_ref_03_artdeco.jpg`
- `reference_bg/`
  - `01_office_sunset.jpg` ... `12_breeze_sign.jpg`

## 重新生成资源

```bash
python3 /Users/test/Desktop/codex程序/定时休息提醒器/BreakReminderApp/DesignAssets/generate_resources.py
```

## 程序加载规则

1. 文件名必须保持不变。
2. 缺失资源时自动回退系统样式，不会崩溃。
3. 程序通过 `DesignAssetLoader` 从 `DesignAssets/` 加载资源。
