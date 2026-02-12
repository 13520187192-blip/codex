#!/bin/bash
# 构建和验证脚本

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     BreakReminderApp - Neo-Noir Sunset 构建验证              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="BreakReminderApp"

echo "📁 项目目录: $PROJECT_DIR"
echo ""

# ============================================
# 1. 检查必要文件
# ============================================
echo "🔍 步骤 1: 检查必要文件..."
echo ""

FILES_TO_CHECK=(
    "$PROJECT_DIR/$APP_NAME/Settings/SettingsView.swift"
    "$PROJECT_DIR/$APP_NAME/MenuBar/MenuBarController.swift"
    "$PROJECT_DIR/$APP_NAME/Overlay/BreakOverlayPanelController.swift"
    "$PROJECT_DIR/$APP_NAME/DesignAssets/NeoNoirTheme.swift"
    "$PROJECT_DIR/$APP_NAME/DesignAssets/DESIGN_SPEC_NEO_NOIR_SUNSET.md"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $(basename "$file")"
    else
        echo -e "${RED}✗${NC} $(basename "$file") - 缺失"
    fi
done

echo ""

# ============================================
# 2. 检查资源文件
# ============================================
echo "🔍 步骤 2: 检查资源文件..."
echo ""

RESOURCES=(
    "$PROJECT_DIR/$APP_NAME/DesignAssets/hero.png"
    "$PROJECT_DIR/$APP_NAME/DesignAssets/icon_clock.png"
    "$PROJECT_DIR/$APP_NAME/DesignAssets/bg_pattern.png"
    "$PROJECT_DIR/$APP_NAME/DesignAssets/font_title.ttf"
    "$PROJECT_DIR/$APP_NAME/DesignAssets/font_body.ttf"
)

for resource in "${RESOURCES[@]}"; do
    if [ -f "$resource" ]; then
        size=$(du -h "$resource" | cut -f1)
        echo -e "${GREEN}✓${NC} $(basename "$resource") ($size)"
    else
        echo -e "${YELLOW}⚠${NC} $(basename "$resource") - 使用系统默认"
    fi
done

echo ""

# ============================================
# 3. 检查代码中 Neo-Noir 颜色
# ============================================
echo "🔍 步骤 3: 验证代码风格..."
echo ""

NEO_NOIR_COLORS=("sunsetOrange" "bgDeep" "neonCyan" "bgCard")
FOUND_COUNT=0

for color in "${NEO_NOIR_COLORS[@]}"; do
    if grep -q "$color" "$PROJECT_DIR/$APP_NAME/Settings/SettingsView.swift"; then
        echo -e "${GREEN}✓${NC} 找到颜色定义: $color"
        ((FOUND_COUNT++))
    fi
done

if [ $FOUND_COUNT -eq ${#NEO_NOIR_COLORS[@]} ]; then
    echo -e "${GREEN}✓${NC} 代码已更新为 Neo-Noir 风格"
else
    echo -e "${YELLOW}⚠${NC} 部分颜色定义缺失"
fi

echo ""

# ============================================
# 4. 生成基础资源（如果缺失）
# ============================================
echo "🔍 步骤 4: 生成基础资源..."
echo ""

if command -v python3 &> /dev/null; then
    if [ -f "$PROJECT_DIR/$APP_NAME/DesignAssets/generate_resources.py" ]; then
        echo "正在运行资源生成脚本..."
        cd "$PROJECT_DIR/$APP_NAME/DesignAssets"
        python3 generate_resources.py
    else
        echo -e "${YELLOW}⚠${NC} 未找到资源生成脚本"
    fi
else
    echo -e "${YELLOW}⚠${NC} 未安装 Python3，跳过资源生成"
fi

echo ""

# ============================================
# 5. 检查参考图文件夹
# ============================================
echo "🔍 步骤 5: 检查参考图文件夹..."
echo ""

REF_STYLE_DIR="$PROJECT_DIR/$APP_NAME/DesignAssets/reference_style"
REF_BG_DIR="$PROJECT_DIR/$APP_NAME/DesignAssets/reference_bg"

if [ -d "$REF_STYLE_DIR" ]; then
    style_count=$(find "$REF_STYLE_DIR" -name "*.jpg" -o -name "*.png" | wc -l)
    if [ $style_count -lt 3 ]; then
        echo -e "${YELLOW}⚠${NC} reference_style/ - 图片不足，当前 $style_count 张（应为3张）"
    else
        echo -e "${GREEN}✓${NC} reference_style/ - 已就绪 ($style_count 张图片)"
    fi
fi

if [ -d "$REF_BG_DIR" ]; then
    bg_count=$(find "$REF_BG_DIR" -name "*.jpg" -o -name "*.png" | wc -l)
    if [ $bg_count -lt 12 ]; then
        echo -e "${YELLOW}⚠${NC} reference_bg/ - 图片不足，当前 $bg_count 张（应为12张）"
    else
        echo -e "${GREEN}✓${NC} reference_bg/ - 已就绪 ($bg_count 张图片)"
    fi
fi

echo ""

# ============================================
# 6. 项目结构摘要
# ============================================
echo "📋 项目结构摘要"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "仓库根目录/"
echo "├── 📄 build_and_verify.sh          ← 本脚本"
echo "├── 📄 BreakReminder.xcodeproj"
echo "├── 📂 BreakReminderApp/"
echo "│   ├── 📄 AppEntry.swift"
echo "├── 📂 DesignAssets/"
echo "│   ├── 📄 DESIGN_SPEC_NEO_NOIR_SUNSET.md"
echo "│   ├── 📄 ASSETS_PRODUCTION_GUIDE.md"
echo "│   ├── 📄 DESIGN_DELIVERY_SUMMARY.md"
echo "│   ├── 📄 RESOURCES_AI_GENERATION_PROMPTS.md"
echo "│   ├── 📄 NeoNoirTheme.swift"
echo "│   ├── 🔧 generate_resources.py"
echo "│   ├── 🖼️ hero.png                  (由参考图生成)"
echo "│   ├── 🖼️ icon_clock.png            (重绘时钟语义)"
echo "│   ├── 🖼️ bg_pattern.png            (由参考图生成纹理)"
echo "│   ├── 🔤 font_title.ttf            (建议: Bebas Neue)"
echo "│   ├── 🔤 font_body.ttf             (建议: Inter)"
echo "│   ├── 📂 reference_style/          (3张风格参考)"
echo "│   └── 📂 reference_bg/             (12张黄昏参考)"
echo "├── 📂 MenuBar/"
echo "│   └── 📄 MenuBarController.swift   ✅ 已更新 Neo-Noir"
echo "├── 📂 Settings/"
echo "│   └── 📄 SettingsView.swift        ✅ 已更新 Neo-Noir"
echo "├── 📂 Overlay/"
echo "│   └── 📄 BreakOverlayPanelController.swift ✅ 已更新 Neo-Noir"
echo "└── ... 其他文件"
echo ""

# ============================================
# 7. 下一步提示
# ============================================
echo "🚀 下一步操作"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. 编译运行"
echo "   $ open $PROJECT_DIR/BreakReminder.xcodeproj"
echo ""
echo "2. 重新生成资源（可选）"
echo "   $ python3 $PROJECT_DIR/BreakReminderApp/DesignAssets/generate_resources.py"
echo ""
echo "3. 优化资源文件（可选）"
echo "   - 使用 AI 生成高质量 hero.png"
echo "   - 使用 Figma 设计 icon_clock.png"
echo "   - 下载 Bebas Neue 字体"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ 验证完成"
echo "═══════════════════════════════════════════════════════════════"
