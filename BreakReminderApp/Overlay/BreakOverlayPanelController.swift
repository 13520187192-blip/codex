import AppKit
import SwiftUI

// MARK: - 颜色扩展

private extension Color {
    static let bgDeep = NeoNoirTheme.Colors.baseBackground
    static let bgCard = NeoNoirTheme.Colors.overlayWine.opacity(0.35)
    static let sunsetOrange = NeoNoirTheme.Colors.overlayRose
    static let sunsetGold = NeoNoirTheme.Colors.sunsetOrange
    static let overlayWine = NeoNoirTheme.Colors.overlayWine
}

// MARK: - 控制器

final class BreakOverlayPanelController: BreakOverlayPresenting {
    private var panel: NSPanel?
    
    func showBreakDue(forceBreakPopup: Bool, onStartBreak: @escaping () -> Void, onSnooze: @escaping () -> Void, onSkip: @escaping () -> Void) {
        let contentView = BreakOverlayView(
            onStartBreak: onStartBreak,
            onSnooze: onSnooze,
            onSkip: onSkip
        )
        
        if panel == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 300),
                styleMask: forceBreakPopup ? [.titled] : [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            panel.title = "休息提醒"
            panel.level = forceBreakPopup ? .screenSaver : .statusBar
            panel.isFloatingPanel = true
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.hidesOnDeactivate = false
            panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
            panel.standardWindowButton(.zoomButton)?.isHidden = true
            panel.standardWindowButton(.closeButton)?.isHidden = forceBreakPopup
            panel.backgroundColor = .clear
            self.panel = panel
        } else {
            panel?.level = forceBreakPopup ? .screenSaver : .statusBar
            panel?.standardWindowButton(.closeButton)?.isHidden = forceBreakPopup
        }
        
        panel?.contentView = NSHostingView(rootView: contentView)
        panel?.center()
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func dismiss() {
        panel?.orderOut(nil)
    }
}

// MARK: - 弹窗视图 (Neo-Noir Sunset 风格)

private struct BreakOverlayView: View {
    let onStartBreak: () -> Void
    let onSnooze: () -> Void
    let onSkip: () -> Void
    @State private var appeared = false
    @State private var glowOpacity: Double = 0.6
    
    var body: some View {
        ZStack {
            // 深色背景
            LinearGradient(
                colors: [Color.bgDeep, Color.overlayWine.opacity(0.72), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
            
            // 暗角效果
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.5)],
                center: .center,
                startRadius: 100,
                endRadius: 250
            )
            .ignoresSafeArea()
            
            // 主内容
            VStack(spacing: 0) {
                // 图标
                Image(systemName: "sun.haze.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.sunsetGold)
                    .shadow(color: .sunsetOrange.opacity(0.6), radius: 20)
                    .padding(.top, 32)
                    .padding(.bottom, 20)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)
                    .animation(NeoNoirTheme.Motion.overlaySpring.delay(0.1), value: appeared)
                
                // 标题
                Text("该休息了")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .tracking(3)
                    .foregroundColor(.white)
                    .shadow(color: .sunsetOrange.opacity(glowOpacity), radius: 10)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            glowOpacity = 1.0
                        }
                    }
                    .padding(.bottom, 8)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(NeoNoirTheme.Motion.cardIn.delay(0.15), value: appeared)
                
                // 渐变分割线
                GradientDivider()
                    .frame(width: 120)
                    .padding(.bottom, 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(NeoNoirTheme.Motion.cardIn.delay(0.2), value: appeared)
                
                // 副标题
                Text("离开屏幕几分钟，活动一下身体。")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(NeoNoirTheme.Motion.cardIn.delay(0.25), value: appeared)
                
                // 主按钮
                Button(action: onStartBreak) {
                    Text("开始休息")
                        .font(.system(size: 15, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                }
                .buttonStyle(SunsetGlowButtonStyle())
                .padding(.bottom, 16)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.9)
                .animation(NeoNoirTheme.Motion.overlaySpring.delay(0.3), value: appeared)
                
                // 次要按钮
                HStack(spacing: 16) {
                    Button("稍后提醒") {
                        onSnooze()
                    }
                    .buttonStyle(NightTextButtonStyle())
                    
                    Button("跳过本次") {
                        onSkip()
                    }
                    .buttonStyle(NightTextButtonStyle())
                }
                .padding(.bottom, 32)
                .opacity(appeared ? 1 : 0)
                .animation(NeoNoirTheme.Motion.cardIn.delay(0.35), value: appeared)
            }
        }
        .frame(width: 420, height: 300)
        .background(
            // Art Deco 风格卡片背景
            ZStack {
                // 卡片底色
                Color.bgCard
                
                // 外层发光边框
                Rectangle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.sunsetOrange.opacity(0.7),
                                Color.overlayWine.opacity(0.4),
                                Color.sunsetOrange.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .shadow(color: .sunsetOrange.opacity(0.2), radius: 20)
                
                // 内层细边框
                Rectangle()
                    .strokeBorder(Color.sunsetOrange.opacity(0.15), lineWidth: 1)
                    .padding(3)
                
                // 四角装饰
                CornerDecorations()
            }
        )
        .onAppear {
            appeared = true
        }
        .scaleEffect(appeared ? 1 : 0.92)
        .animation(NeoNoirTheme.Motion.overlaySpring, value: appeared)
    }
}

// MARK: - 按钮样式

private struct SunsetGlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack(alignment: .leading) {
                    Color.bgCard.opacity(0.8)
                    Rectangle()
                        .fill(Color.sunsetOrange)
                        .frame(width: 4)
                        .shadow(color: .sunsetOrange.opacity(0.6), radius: 6)
                }
            )
            .overlay(
                Rectangle()
                    .strokeBorder(Color.sunsetOrange.opacity(configuration.isPressed ? 0.6 : 0.4), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(NeoNoirTheme.Motion.buttonPress, value: configuration.isPressed)
    }
}

private struct NightTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .tracking(0.5)
            .foregroundColor(.white.opacity(configuration.isPressed ? 1 : 0.6))
            .underline(configuration.isPressed, color: .sunsetOrange.opacity(0.5))
            .animation(NeoNoirTheme.Motion.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - 装饰组件

private struct GradientDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, Color.sunsetOrange, Color.sunsetGold, Color.sunsetOrange, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
    }
}

private struct CornerDecorations: View {
    var body: some View {
        GeometryReader { geo in
            let size: CGFloat = 20
            let inset: CGFloat = 6
            
            ZStack {
                // 左上
                Path { path in
                    path.move(to: CGPoint(x: inset, y: inset + size))
                    path.addLine(to: CGPoint(x: inset, y: inset))
                    path.addLine(to: CGPoint(x: inset + size, y: inset))
                }
                .stroke(Color.sunsetOrange, lineWidth: 2)
                
                // 右上
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width - inset - size, y: inset))
                    path.addLine(to: CGPoint(x: geo.size.width - inset, y: inset))
                    path.addLine(to: CGPoint(x: geo.size.width - inset, y: inset + size))
                }
                .stroke(Color.sunsetOrange, lineWidth: 2)
                
                // 右下
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset - size))
                    path.addLine(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset))
                    path.addLine(to: CGPoint(x: geo.size.width - inset - size, y: geo.size.height - inset))
                }
                .stroke(Color.sunsetOrange, lineWidth: 2)
                
                // 左下
                Path { path in
                    path.move(to: CGPoint(x: inset + size, y: geo.size.height - inset))
                    path.addLine(to: CGPoint(x: inset, y: geo.size.height - inset))
                    path.addLine(to: CGPoint(x: inset, y: geo.size.height - inset - size))
                }
                .stroke(Color.sunsetOrange, lineWidth: 2)
            }
        }
    }
}
