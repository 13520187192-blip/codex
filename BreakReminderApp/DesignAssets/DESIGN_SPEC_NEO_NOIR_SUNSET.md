# Neo-Noir Sunset 设计规范

## 设计理念

融合 **Neo-Noir 新黑色电影** 的深邃神秘与 **Golden Hour 黄昏** 的温暖治愈。

> 就像城市夜幕降临前的那一刻，天空燃烧着最后的橙红，而大地已沉入深蓝。

---

## 一、配色系统

### 主色调（从12张黄昏图提取）

```
背景层：
├── bg-deep:      #0a0a0f      (夜幕黑)
├── bg-midnight:  #0f1729      (午夜蓝)
├── bg-dusk:      #1a1a2e      (黄昏紫)
└── bg-card:      #161b2e      (卡片背景)

黄昏渐变：
├── sunset-orange:  #ff6b35    (落日橙)
├── sunset-gold:    #f4a261    (夕阳金)
├── sunset-pink:    #e07a8a    (晚霞粉)
└── sunset-purple:  #6b5b95    (暮光紫)

荧光强调（从风格参考）：
├── neon-cyan:      #2dd4bf    (霓虹青)
├── neon-lime:      #39ff14    (荧光绿)
└── neon-orange:    #ff8c42    (荧光橙)

文字色：
├── text-primary:   #ffffff    (纯白)
├── text-secondary: rgba(255,255,255,0.75)
├── text-muted:     rgba(255,255,255,0.5)
└── text-accent:    #ff6b35    (橙色强调)

边框与装饰：
├── border-subtle:  rgba(255,107,53,0.2)
├── border-accent:  rgba(255,107,53,0.5)
└── glow-orange:    rgba(255,107,53,0.3)
```

### 配色应用规则

| 场景 | 背景 | 强调 | 文字 |
|------|------|------|------|
| 工作模式 | bg-deep | neon-cyan #2dd4bf | white |
| 休息模式 | bg-midnight | sunset-orange #ff6b35 | white |
| 提醒弹窗 | bg-card + 暗角 | sunset-gold #f4a261 | white |
| 设置窗口 | bg-dusk渐变 | sunset-purple #6b5b95 | white |

---

## 二、字体排版系统

### 字体选择

```
标题字体：Bebas Neue / Oswald / 或 Inter 压缩版
- 特点：窄体、大写、高冲击力
- 用途：主标题、倒计时数字、按钮文字

正文字体：Inter / SF Pro
- 特点：清晰、现代、屏幕优化
- 用途：说明文字、设置项、状态提示

装饰字体：Playfair Display (Italic)
- 特点：优雅衬线、斜体
- 用途：引语、装饰性文字、副标题
```

### 字体层级

| 元素 | 字体 | 大小 | 字重 | 字间距 | 样式 |
|------|------|------|------|--------|------|
| 弹窗大标题 | Bebas Neue | 36px | 400 | 0.15em | 大写 |
| 倒计时数字 | Oswald | 48px | 300 | 0.05em | 等宽数字 |
| 模式标签 | Bebas Neue | 14px | 400 | 0.3em | 大写 |
| 按钮文字 | Bebas Neue | 15px | 400 | 0.1em | 大写 |
| 设置标题 | Inter | 13px | 600 | 0.05em | 正常 |
| 正文 | Inter | 12px | 400 | 0 | 正常 |
| 小标签 | Inter | 10px | 500 | 0.1em | 大写 |

### 排版风格

```
【弹窗标题示例】

        该  休  息  了
    ═══════════════════
    
    离开屏幕几分钟
    活动一下身体
    
    [  开 始 休 息  ]
```

特点：
- 标题字间距拉宽，营造呼吸感
- 分割线使用渐变，中间亮两头暗
- 按钮文字全大写，字间距适中

---

## 三、按钮设计

### 主按钮 - "Sunset Glow" 风格

```
视觉描述：
┌──────────────────────────────────┐
│█                                 │  ← 左侧4px橙色光条
│      ▶  开 始 休 息              │
│                                 │
└──────────────────────────────────┘
      ↑ 微弱橙色外发光
```

**样式规范**：
- 背景：#1a1a2e（半透明）
- 左侧光条：sunset-orange #ff6b35，4px宽
- 光条发光：box-shadow: 0 0 10px #ff6b35
- 边框：1px solid rgba(255,107,53,0.3)
- 圆角：4px（微圆角）
- 文字：Bebas Neue，15px，大写，字间距0.1em
- 内边距：14px 40px

**动效**：
- 悬停：光条亮度+20%，整体向右移动2px
- 按下：scale(0.97)，光条亮度+40%
- 过渡：200ms ease-out

### 次按钮 - "Night Outline" 风格

```
┌──────────────────────────────────┐
│                                  │
│        稍 后 提 醒               │
│                                  │
└──────────────────────────────────┘
  ↑ 1px细边框，微弱发光
```

**样式规范**：
- 背景：transparent
- 边框：1px solid rgba(255,255,255,0.2)
- 文字：Inter，13px，大写，rgba(255,255,255,0.8)
- 悬停：边框变亮至0.5，背景微白 rgba(255,255,255,0.05)

### 危险按钮 - "Deep Red" 风格

```
┌──────────────────────────────────┐
│▓▓                               │  ← 左侧酒红色条
│       跳 过 本 次                │
│                                 │
└──────────────────────────────────┘
```

**样式规范**：
- 左侧光条：burgundy #8b2635
- 其余同主按钮

---

## 四、弹窗卡片设计（Art Deco + Sunset）

### 卡片结构

```
         ◢════════════════════════════◣
        ╱ ▱                          ▱ ╲    ← 上角装饰
       ╱                                ╲
      │                                  │
      │         🌅  图标                 │
      │                                  │
      │      该    休    息    了        │    ← 大字标题
      │    ════════════════════════     │    ← 渐变分割线
      │                                  │
      │      离开屏幕几分钟，            │    ← 正文
      │      活动一下身体。              │
      │                                  │
      │    ┌────────────────────┐       │    ← 主按钮
      │    │  ▶  开 始 休 息     │       │
      │    └────────────────────┘       │
      │                                  │
      │         [稍后] [跳过]            │    ← 次按钮组
      │                                  │
       ╲ ▰                          ▰ ╱    ← 下角装饰
        ◥════════════════════════════◤
        ↑ 双层边框 + 外发光
```

### 样式规范

**卡片容器**：
- 背景：#161b2e（近黑蓝）
- 内边距：40px
- 圆角：8px

**双层边框**：
- 外层：2px solid rgba(255,107,53,0.4)
- 内层：1px solid rgba(255,107,53,0.15)
- 外发光：0 0 40px rgba(255,107,53,0.15)

**角落装饰**（三角形）：
- 大小：16px
- 颜色：sunset-orange #ff6b35
- 位置：四角内嵌

**分割线**：
- 渐变：transparent → #ff6b35 → transparent
- 高度：2px
- 宽度：60%
- 居中

---

## 五、背景设计

### 设置窗口背景

```swift
// 深蓝紫渐变 + 黄昏纹理
LinearGradient(
    colors: [
        Color(#colorLiteral(red: 0.04, green: 0.04, blue: 0.06, alpha: 1)),    // #0a0a0f
        Color(#colorLiteral(red: 0.06, green: 0.09, blue: 0.16, alpha: 1)),    // #0f1729
        Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.18, alpha: 1))       // #1a1a2e
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### 纹理叠加

- 使用 bg_pattern.png 平铺
- 透明度：10%
- 混合模式：overlay
- 纹理特征：细微噪点或斜线纹理

### 暗角效果

```swift
RadialGradient(
    colors: [
        .clear,
        Color.black.opacity(0.4)
    ],
    center: .center,
    startRadius: 100,
    endRadius: 400
)
```

---

## 六、动画效果

### 1. 弹窗出现（戏剧化入场）

```
时长：400ms
曲线：cubic-bezier(0.175, 0.885, 0.32, 1.275) (ease-out-back)

步骤：
0ms   - opacity: 0, scale: 0.85, y: 20px
100ms - 背景遮罩渐显
400ms - opacity: 1, scale: 1, y: 0

附加：
- 边框发光从0到100%
- 装饰角从外向内滑入
```

### 2. 按钮悬停（霓虹响应）

```
时长：200ms
曲线：ease-out

效果：
- 左侧光条亮度 +30%
- 整体 x +2px
- 外发光扩散
```

### 3. 倒计时脉冲（呼吸感）

```
时长：2000ms
循环：infinite

效果：
- 数字阴影发光强度变化
- 0%: opacity 0.6
- 50%: opacity 1.0
- 100%: opacity 0.6
```

### 4. 状态切换（颜色过渡）

```
时长：300ms
曲线：ease-in-out

工作模式 → 休息模式：
- 强调色从 cyan #2dd4bf 渐变到 orange #ff6b35
- 背景色微调
- 光条颜色同步变化
```

---

## 七、图标设计

### icon_clock.png (256x256)

风格：
- 扁平化 + 微渐变
- 主色：sunset-orange 到 sunset-gold 渐变
- 背景：透明或深色圆形底
- 造型：简约时钟，指针指向休息时刻（如3点或6点）

### hero.png (880x560)

风格：
- 黄昏城市剪影或海边日落
- 色调：橙黄紫渐变
- 氛围：放松、治愈、期待休息
- 右侧留有文字空间（渐变遮罩）

### bg_pattern.png (512x512, 无缝)

风格：
- 细微噪点纹理或斜网格
- 颜色：纯白或微橙
- 透明度：使用时10%
- 用途：背景质感叠加

---

## 八、资源文件清单

| 文件名 | 规格 | 制作要点 |
|--------|------|----------|
| hero.png | 880x560 | 黄昏风景，右侧渐变遮罩 |
| bg_pattern.png | 512x512 无缝 | 细微纹理，低对比度 |
| icon_clock.png | 256x256 | 橙金渐变，简约时钟 |
| font_title.ttf | TTF | Bebas Neue 或 Oswald |
| font_body.ttf | TTF | Inter Regular |

---

## 九、代码颜色映射（给程序员）

```swift
// 需要修改的文件：
// - Settings/SettingsView.swift
// - MenuBar/MenuBarController.swift
// - Overlay/BreakOverlayPanelController.swift

extension Color {
    // 背景
    static let bgDeep = Color(#colorLiteral(red: 0.04, green: 0.04, blue: 0.06, alpha: 1))
    static let bgMidnight = Color(#colorLiteral(red: 0.06, green: 0.09, blue: 0.16, alpha: 1))
    static let bgCard = Color(#colorLiteral(red: 0.09, green: 0.11, blue: 0.18, alpha: 1))
    
    // 黄昏色
    static let sunsetOrange = Color(#colorLiteral(red: 1, green: 0.42, blue: 0.21, alpha: 1))
    static let sunsetGold = Color(#colorLiteral(red: 0.96, green: 0.64, blue: 0.38, alpha: 1))
    static let sunsetPurple = Color(#colorLiteral(red: 0.42, green: 0.36, blue: 0.58, alpha: 1))
    
    // 荧光色
    static let neonCyan = Color(#colorLiteral(red: 0.18, green: 0.83, blue: 0.75, alpha: 1))
    
    // 文字
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.75)
    static let textMuted = Color.white.opacity(0.5)
}
```

---

## 设计总结

> **"当城市的霓虹亮起，天空还剩最后一抹橙红。"
> 这是属于工作者的黄昏时刻——提醒你停下，呼吸，休息。**

核心视觉记忆点：
1. 深邃的背景（夜幕黑 + 午夜蓝）
2. 温暖的橙光（落日橙光条 + 发光效果）
3. 戏剧化的弹窗（Art Deco边框 + 四角装饰）
4. 电影感的字体（窄体大写 + 宽字间距）
