# AI 资源生成提示词大全

使用这些提示词通过 AI 图像生成工具（Midjourney/Stable Diffusion/DALL-E）或设计工具生成资源文件。

---

## 一、Hero 图 (880x560)

### 提示词 1 - 城市黄昏

```
City skyline silhouette at golden hour sunset, warm orange and deep purple gradient sky, modern glass buildings reflecting sunset light, calm and peaceful atmosphere, cinematic composition, right side fading to dark gradient for text overlay, minimal noise, 880x560 aspect ratio, macOS app background style, low saturation, moody lighting --ar 880:560 --v 6
```

### 提示词 2 - 海边日落

```
Minimalist ocean sunset scene, warm orange sun touching horizon, calm sea water reflection, distant island silhouettes, gradient sky from deep blue to golden orange, peaceful mood, right side dark gradient for UI text, clean composition, suitable for macOS app background --ar 880:560 --v 6
```

### 提示词 3 - 抽象黄昏

```
Abstract gradient background, sunset colors transitioning from deep midnight blue #0f1729 through purple to warm orange #ff6b35, subtle texture, soft glow effects, minimalist, perfect for macOS application hero image, right side darker for text overlay --ar 880:560 --v 6
```

**导出设置**：
- 格式：PNG
- 尺寸：880x560
- 颜色空间：sRGB

---

## 二、图标 (256x256)

### 提示词 1 - 简约时钟

```
Minimalist clock icon, flat design, sunset orange to golden gradient fill #ff6b35 to #f4a261, simple circular outline, clock hands pointing to 3 o'clock, subtle glow effect, dark transparent background, macOS Big Sur style icon, clean geometric shapes, 256x256 --ar 1:1 --v 6
```

### 提示词 2 - 抽象时钟

```
Abstract time concept icon, sun-like circle with gradient from orange #ff6b35 to deep blue #0f1729, minimalist design, clock hands silhouette, glowing effect, modern app icon style, transparent background, suitable for 256x256 macOS icon --ar 1:1 --v 6
```

### 提示词 3 - 几何时钟

```
Geometric clock icon, Art Deco style, sunset color palette, golden hour tones, stylized clock face with elegant hands, minimal details, gradient fill, professional macOS application icon, 256x256 pixels --ar 1:1 --v 6
```

**导出设置**：
- 格式：PNG
- 尺寸：256x256
- 透明背景：是

---

## 三、背景纹理 (512x512 无缝)

### 提示词 1 - 噪点纹理

```
Seamless subtle noise texture, black background with very subtle white noise dots, 5% opacity noise, uniform distribution, tileable pattern, suitable for dark mode UI background, 512x512 pixels, no visible seams when tiled --ar 1:1 --v 6
```

### 提示词 2 - 斜线纹理

```
Seamless diagonal line pattern, 45 degree angle, very thin white lines #ffffff on pure black #0a0a0a background, line spacing 8 pixels, line thickness 0.5px, subtle and minimal, tileable texture for UI background, 512x512 --ar 1:1 --v 6
```

### 提示词 3 - 网格纹理

```
Minimalist grid pattern, very subtle lines, sunset orange #ff6b35 at 10% opacity on dark background #0a0a0a, square grid, seamless tileable texture, suitable for dark mode app background, 512x512 pixels --ar 1:1 --v 6
```

**导出设置**：
- 格式：PNG
- 尺寸：512x512
- 无缝：确保可平铺

---

## 四、字体选择（无需生成，直接下载）

### 标题字体 - Bebas Neue

**下载链接**：
- Google Fonts: https://fonts.google.com/specimen/Bebas+Neue
- GitHub: https://github.com/dharmatype/Bebas-Neue

**安装步骤**：
1. 下载 TTF 文件
2. 重命名为 `font_title.ttf`
3. 放入 `DesignAssets/` 文件夹

### 正文字体 - Inter

**下载链接**：
- Google Fonts: https://fonts.google.com/specimen/Inter
- GitHub: https://github.com/rsms/inter

**安装步骤**：
1. 下载 TTF 文件（Regular 和 Medium）
2. 重命名为 `font_body.ttf`
3. 放入 `DesignAssets/` 文件夹

---

## 五、快速生成脚本（Python）

如果需要程序化生成简单纹理，使用以下 Python 脚本：

### 生成噪点纹理

```python
from PIL import Image, ImageDraw
import random

# 创建噪点纹理
width, height = 512, 512
img = Image.new('RGBA', (width, height), (10, 10, 15, 255))  # #0a0a0f
draw = ImageDraw.Draw(img)

# 添加噪点
for _ in range(5000):
    x = random.randint(0, width-1)
    y = random.randint(0, height-1)
    alpha = random.randint(5, 20)  # 非常淡
    draw.point((x, y), fill=(255, 255, 255, alpha))

img.save('bg_pattern.png')
print("Generated bg_pattern.png")
```

### 生成斜线纹理

```python
from PIL import Image, ImageDraw

width, height = 512, 512
img = Image.new('RGBA', (width, height), (10, 10, 15, 0))  # 透明
draw = ImageDraw.Draw(img)

# 绘制斜线
spacing = 16
for i in range(-height, width + height, spacing):
    draw.line([(i, 0), (i + height, height)], 
              fill=(255, 255, 255, 8), width=1)  # 非常淡的白线

img.save('bg_pattern_diagonal.png')
print("Generated bg_pattern_diagonal.png")
```

---

## 六、Figma 设计模板

如果使用 Figma，创建以下组件：

### 1. Hero 图框架
- 画板尺寸：880x560
- 背景：深紫到橙渐变 #0f1729 → #ff6b35
- 叠加：右侧渐变遮罩（黑到透明）
- 导出：PNG

### 2. 图标框架
- 画板尺寸：256x256
- 背景：透明
- 主元素：圆形 + 时钟指针
- 填充：橙金渐变 #ff6b35 → #f4a261
- 导出：PNG

### 3. 纹理框架
- 画板尺寸：512x512
- 背景：#0a0a0f
- 元素：细微噪点或斜线
- 导出：PNG

---

## 七、资源验证清单

生成后检查：

| 文件 | 尺寸 | 格式 | 透明度 | 检查项 |
|------|------|------|--------|--------|
| hero.png | 880x560 | PNG | 否 | 右侧有暗渐变 |
| icon_clock.png | 256x256 | PNG | 是 | 渐变填充 |
| bg_pattern.png | 512x512 | PNG | 可选 | 可无缝平铺 |
| font_title.ttf | - | TTF | - | Bebas Neue |
| font_body.ttf | - | TTF | - | Inter |

---

## 八、替代方案

如果无法生成，使用以下免费资源：

### 免费图标
- SF Symbols: clock.fill, timer, hourglass
- Remix Icon: time-line, alarm-warning-line
- Phosphor Icons: clock, timer

### 免费纹理
- Subtle Patterns: https://www.toptal.com/designers/subtlepatterns/
- Transparent Textures: https://www.transparenttextures.com/

### 免费字体
- Google Fonts: Bebas Neue, Inter, Oswald, Roboto Condensed
- Adobe Fonts: 需要订阅

---

## 九、最终文件结构

```
DesignAssets/
├── hero.png                    ← AI生成或设计工具制作
├── icon_clock.png              ← AI生成或设计工具制作
├── bg_pattern.png              ← AI生成或Python脚本
├── font_title.ttf              ← 下载 Bebas Neue
├── font_body.ttf               ← 下载 Inter
│
├── reference_style/            ← 放入3张风格参考图
│   ├── style_ref_01_gia.jpg
│   ├── style_ref_02_neon.jpg
│   └── style_ref_03_artdeco.jpg
│
└── reference_bg/               ← 放入12张黄昏参考图
    ├── 01_office_sunset.jpg
    ├── 02_sea_dusk.jpg
    └── ...
```

---

**生成完成后，直接替换现有文件即可。**
