// Neo-Noir Sunset 样式扩展
// 复制到项目中使用

import SwiftUI

// MARK: - 颜色扩展

extension Color {
    // 背景色
    static let bgDeep = Color(#colorLiteral(red: 0.04, green: 0.04, blue: 0.06, alpha: 1))
    static let bgMidnight = Color(#colorLiteral(red: 0.06, green: 0.09, blue: 0.16, alpha: 1))
    static let bgDusk = Color(#colorLiteral(red: 0.1, green: 0.1, blue: 0.18, alpha: 1))
    static let bgCard = Color(#colorLiteral(red: 0.09, green: 0.11, blue: 0.18, alpha: 1))
    
    // 黄昏色
    static let sunsetOrange = Color(#colorLiteral(red: 1, green: 0.42, blue: 0.21, alpha: 1))
    static let sunsetGold = Color(#colorLiteral(red: 0.96, green: 0.64, blue: 0.38, alpha: 1))
    static let sunsetPink = Color(#colorLiteral(red: 0.88, green: 0.48, blue: 0.54, alpha: 1))
    static let sunsetPurple = Color(#colorLiteral(red: 0.42, green: 0.36, blue: 0.58, alpha: 1))
    
    // 荧光色
    static let neonCyan = Color(#colorLiteral(red: 0.18, green: 0.83, blue: 0.75, alpha: 1))
    static let neonLime = Color(#colorLiteral(red: 0.22, green: 1, blue: 0.08, alpha: 1))
    
    // 边框
    static let borderSubtle = Color.white.opacity(0.15)
    static let borderAccent = Color.sunsetOrange.opacity(0.4)
}

// MARK: - 按钮样式

struct SunsetGlowButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    var accentColor: Color = .sunsetOrange
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .default))
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(
                ZStack(alignment: .leading) {
                    // 背景
                    Color.bgCard.opacity(0.8)
                    
                    // 左侧光条
                    Rectangle()
                        .fill(accentColor)
                        .frame(width: 4)
                        .shadow(color: accentColor.opacity(0.6), radius: 6, x: 0, y: 0)
                }
            )
            .overlay(
                Rectangle()
                    .strokeBorder(accentColor.opacity(0.35), lineWidth: 1)
            )
            .offset(x: configuration.isPressed ? 0 : (isPrimary ? 1 : 0))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct NightOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .textCase(.uppercase)
            .tracking(1)
            .foregroundColor(.white.opacity(0.85))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Color.clear
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.white.opacity(configuration.isPressed ? 0.4 : 0.25), lineWidth: 1)
                    )
            )
            .background(
                Color.white.opacity(configuration.isPressed ? 0.08 : 0)
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - 弹窗卡片样式

struct ArtDecoCard: ViewModifier {
    var accentColor: Color = .sunsetOrange
    
    func body(content: Content) -> some View {
        content
            .padding(32)
            .background(
                Color.bgCard
                    .overlay(
                        // 内层边框
                        Rectangle()
                            .strokeBorder(accentColor.opacity(0.15), lineWidth: 1)
                            .padding(2)
                    )
            )
            .overlay(
                // 外层边框 + 发光
                Rectangle()
                    .strokeBorder(accentColor.opacity(0.4), lineWidth: 2)
                    .shadow(color: accentColor.opacity(0.2), radius: 20, x: 0, y: 0)
            )
            .overlay(
                // 四角装饰
                GeometryReader { geo in
                    ZStack {
                        // 左上
                        CornerDecoration()
                            .frame(width: 16, height: 16)
                            .position(x: 8, y: 8)
                        
                        // 右上
                        CornerDecoration()
                            .frame(width: 16, height: 16)
                            .rotationEffect(.degrees(90))
                            .position(x: geo.size.width - 8, y: 8)
                        
                        // 右下
                        CornerDecoration()
                            .frame(width: 16, height: 16)
                            .rotationEffect(.degrees(180))
                            .position(x: geo.size.width - 8, y: geo.size.height - 8)
                        
                        // 左下
                        CornerDecoration()
                            .frame(width: 16, height: 16)
                            .rotationEffect(.degrees(270))
                            .position(x: 8, y: geo.size.height - 8)
                    }
                }
            )
    }
}

struct CornerDecoration: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 16))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 16, y: 0))
        }
        .stroke(Color.sunsetOrange, lineWidth: 2)
    }
}

// MARK: - 渐变分割线

struct GradientDivider: View {
    var color: Color = .sunsetOrange
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        color,
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
    }
}

// MARK: - 背景层

struct NeoNoirBackground: View {
    var body: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.06),
                    Color(red: 0.06, green: 0.09, blue: 0.16),
                    Color(red: 0.1, green: 0.1, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 暗角
            RadialGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.4)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - View 扩展

extension View {
    func artDecoCard(accentColor: Color = .sunsetOrange) -> some View {
        modifier(ArtDecoCard(accentColor: accentColor))
    }
}

// MARK: - 字体工具

struct SunsetFont {
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    static func headline(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .semibold, design: .default)
            .uppercaseSmallCaps()
    }
    
    static func bodyText(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func caption(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .medium, design: .default)
            .uppercaseSmallCaps()
    }
}

// 字间距扩展
extension View {
    func wideTracking(_ value: CGFloat = 2) -> some View {
        self.tracking(value)
    }
}
