# 资源文件制作指南

基于 Neo-Noir Sunset 设计规范的资源制作说明。

---

## 一、字体文件

### font_title.ttf（标题字体）

**推荐字体**：
1. **Bebas Neue**（首选）- 免费商用
   - 特点：窄体、全大写、高冲击力
   - 下载：https://fonts.google.com/specimen/Bebas+Neue
   
2. **Oswald**（备选）
   - 特点：压缩风格、现代感
   - 下载：https://fonts.google.com/specimen/Oswald

**制作要求**：
- 格式：TTF
- 字重：Regular (400) 和 Bold (700)
- 如果需要粗体效果，使用 Bold 字重

### font_body.ttf（正文字体）

**推荐字体**：
- **Inter**（保持现有）
  - 下载：https://fonts.google.com/specimen/Inter

**制作要求**：
- 格式：TTF
- 字重：Regular (400) 和 Medium (500)

---

## 二、图标文件

### icon_clock.png (256x256)

**设计理念**：
黄昏时刻的时钟，象征工作与休息的转换。

**视觉风格**：
- 扁平化 + 微渐变
- 主色：落日橙 (#ff6b35) 到夕阳金 (#f4a261) 渐变
- 背景：透明或深色圆形底

**制作步骤**：
1. 创建 256x256 画布
2. 绘制简约时钟轮廓（圆形）
3. 指针指向 3:00 或 6:00（象征休息时刻）
4. 添加渐变填充（橙到金）
5. 添加微弱发光效果
6. 导出 PNG（保留透明背景）

**参考构图**：
```
    ╭──────────╮
   ╱     │      ╲
  │      ●       │  ← 中心点
  │   ╱      ╲   │  ← 时针指向3点
  │            │  
   ╲    ───    ╱   ← 分针指向12点
    ╰──────────╯
```

---

## 三、Hero 图

### hero.png (880x560)

**设计理念**：
黄昏城市剪影或海边日落，营造休息前的宁静氛围。

**视觉风格**：
- 色调：暖橙、金黄、深紫蓝的黄昏渐变
- 氛围：放松、治愈、期待
- 构图：右侧留出文字空间

**制作要点**：
1. 选择黄昏风景素材（城市或海边）
2. 调整色调为暖色系
3. 右侧添加渐变遮罩（从透明到深色）
4. 整体降低饱和度 10-20%
5. 导出 PNG

**渐变遮罩**：
```
┌─────────────────────────────────┐
│                        ░░░░░░░░ │  ← 左侧清晰
│                      ░░░░░░░░░░ │
│                    ░░░░░░░░░░░░ │  ← 右侧渐变遮罩
│                  ░░░░░░░░░░░░░░ │    方便叠加文字
│                ░░░░░░░░░░░░░░░░ │
└─────────────────────────────────┘
```

**参考场景**：
- 城市天际线剪影 + 橙色天空
- 海边日落 + 远山轮廓
- 高楼大厦玻璃反光 + 黄昏

---

## 四、背景纹理

### bg_pattern.png (512x512, 无缝平铺)

**设计理念**：
细微的噪点或斜线纹理，增加背景的质感层次。

**视觉风格**：
- 极简、低对比度
- 颜色：白色或微橙色
- 透明度：使用时设为 8-10%

**制作步骤**：

**方案 A：噪点纹理**
1. 创建 512x512 画布
2. 填充纯黑
3. 添加噪点（Noise）滤镜
4. 噪点强度：5-10%
5. 导出 PNG

**方案 B：斜线纹理**
1. 创建 512x512 画布
2. 绘制 45° 细线（1px 宽）
3. 线条间距：8-12px
4. 线条颜色：白色（低透明度）
5. 导出 PNG

**无缝处理**：
确保纹理可以无缝平铺，没有明显接缝。

---

## 五、快速制作流程

### 如果你有设计软件（Figma/Sketch/PS）

1. **字体**：
   - 下载 Bebas Neue 和 Inter
   - 直接复制 TTF 文件到 DesignAssets/

2. **图标**：
   - 使用 SF Symbols 或图标库找到时钟图标
   - 应用橙金渐变
   - 导出 256x256 PNG

3. **Hero 图**：
   - 从 12 张黄昏参考图中选一张最喜欢的
   - 裁剪为 880x560
   - 右侧添加渐变遮罩
   - 导出 PNG

4. **纹理**：
   - 使用现有噪点纹理，或创建简单斜线
   - 确保 512x512 无缝
   - 导出 PNG

### 如果你使用 AI 生成

**提示词模板**：

**icon_clock.png**：
```
Minimalist clock icon, flat design, sunset orange to golden gradient, 
soft glow, dark background, 256x256, transparent background, 
modern macOS icon style, simple geometric shapes
```

**hero.png**：
```
City skyline silhouette at sunset, warm orange and purple gradient sky,
calm atmosphere, 880x560 aspect ratio, right side fading to dark,
low saturation, cinematic mood, for macOS app background
```

**bg_pattern.png**：
```
Seamless subtle noise texture, 512x512, very low contrast,
white on black, 5% opacity noise, tileable pattern
```

---

## 六、文件清单与检查

| 文件名 | 规格 | 状态 |
|--------|------|------|
| font_title.ttf | TTF, Bebas Neue | ☐ 待制作 |
| font_body.ttf | TTF, Inter | ☐ 待制作 |
| icon_clock.png | 256x256, 橙金渐变 | ☐ 待制作 |
| hero.png | 880x560, 黄昏风景 | ☐ 待制作 |
| bg_pattern.png | 512x512, 无缝纹理 | ☐ 待制作 |

---

## 七、替换说明

制作完成后，直接替换 DesignAssets/ 文件夹中的同名文件即可。

程序会自动加载新的资源文件。

**注意**：保持文件名完全一致，包括大小写。
