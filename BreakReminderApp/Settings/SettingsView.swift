import AppKit
import SwiftUI

// MARK: - 颜色扩展 (Neo-Noir Sunset)

private extension Color {
    static let bgDeep = NeoNoirTheme.Colors.baseBackground
    static let bgMidnight = NeoNoirTheme.Colors.deepBlue.opacity(0.5)
    static let bgDusk = NeoNoirTheme.Colors.deepBlue.opacity(0.35)
    static let bgCard = NeoNoirTheme.Colors.card

    static let sunsetOrange = NeoNoirTheme.Colors.sunsetOrange
    static let sunsetGold = NeoNoirTheme.Colors.sunsetOrange.opacity(0.85)
    static let neonCyan = NeoNoirTheme.Colors.focusAccent
}

// MARK: - 按钮样式

private struct SunsetGlowButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    var accentColor: Color = .sunsetOrange
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .tracking(1.2)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                ZStack(alignment: .leading) {
                    Color.bgCard.opacity(0.6)
                    Rectangle()
                        .fill(accentColor)
                        .frame(width: 3)
                        .shadow(color: accentColor.opacity(0.5), radius: 4, x: 0, y: 0)
                }
            )
            .overlay(
                Rectangle()
                    .strokeBorder(accentColor.opacity(0.35), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(NeoNoirTheme.Motion.buttonPress, value: configuration.isPressed)
    }
}

private struct NightOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .tracking(0.8)
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .strokeBorder(Color.white.opacity(configuration.isPressed ? 0.4 : 0.2), lineWidth: 1)
            )
            .background(Color.white.opacity(configuration.isPressed ? 0.05 : 0))
    }
}

// MARK: - 主设置窗口

struct SettingsWindowView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var appeared = false
    private let assetLoader = DesignAssetLoader.shared
    
    var body: some View {
        ZStack {
            // Neo-Noir 背景
            NeoNoirBackground()
            
            VStack(alignment: .leading, spacing: 20) {
                header
                
                Text(viewModel.statusLine)
                    .font(assetLoader.bodyFont(size: 13, weight: .medium))
                    .foregroundColor(NeoNoirTheme.Colors.textMuted)
                    .tracking(0.5)
                
                SettingsPanelView(store: viewModel.settingsStore) {
                    viewModel.playPreviewSound()
                }
                
                HStack(spacing: 12) {
                    Button("退出应用") {
                        viewModel.quitApplication()
                    }
                    .buttonStyle(NightOutlineButtonStyle())

                    Button("检查更新") {
                        viewModel.checkForUpdatesNow()
                    }
                    .buttonStyle(SunsetGlowButtonStyle(isPrimary: false, accentColor: .neonCyan))
                    
                    Spacer()
                    
                    Button("关闭窗口") {
                        viewModel.closeWindow()
                    }
                    .buttonStyle(NightOutlineButtonStyle())
                }
            }
            .padding(28)
            .background(
                Color.bgCard.opacity(0.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: NeoNoirTheme.Metrics.cornerRadius, style: .continuous)
                            .strokeBorder(Color.sunsetOrange.opacity(0.15), lineWidth: 1)
                    )
            )
            .cornerRadius(NeoNoirTheme.Metrics.cornerRadius)
            .padding(24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(NeoNoirTheme.Motion.cardIn, value: appeared)
        }
        .frame(minWidth: 820, minHeight: 640)
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bgCard)
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.sunsetOrange.opacity(0.4), lineWidth: 1.5)
                    )
                
                if let icon = assetLoader.clockIconImage() {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "clock.badge")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.sunsetOrange)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("休息提醒设置")
                    .font(assetLoader.titleFont(size: 28))
                    .tracking(1)
                    .foregroundColor(.white)
                
                Text("窗口可关闭，应用会继续在菜单栏运行")
                    .font(assetLoader.bodyFont(size: 12))
                    .foregroundColor(NeoNoirTheme.Colors.textMuted)
                    .tracking(0.3)
            }
            
            Spacer()
            
            // Hero 图
            if let hero = assetLoader.heroImage() {
                ZStack {
                    Image(nsImage: hero)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 86)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.32)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .frame(width: 140, height: 86)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(NeoNoirTheme.Colors.subtleBorder, lineWidth: 1)
                )
                .opacity(0.95)
            }
        }
    }
}

// MARK: - 背景组件

private struct NeoNoirBackground: View {
    var body: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                colors: [
                    NeoNoirTheme.Colors.baseBackground,
                    NeoNoirTheme.Colors.deepBlue.opacity(0.6),
                    NeoNoirTheme.Colors.sunsetOrange.opacity(0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 纹理
            if let pattern = DesignAssetLoader.shared.backgroundPatternImage() {
                Image(nsImage: pattern)
                    .resizable(resizingMode: .tile)
                    .opacity(0.08)
                    .blendMode(.overlay)
            }
            
            // 暗角
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.35)],
                center: .center,
                startRadius: 150,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - 设置面板

struct SettingsPanelView: View {
    @ObservedObject var store: SettingsStore
    var onPreviewSound: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("提醒参数")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white)
                .textCase(.uppercase)

            SettingsSectionCard(title: "时间设置（1~60 分钟）") {
                StepperControlRow(title: "提醒间隔", value: $store.workDurationMinutes, range: ReminderConfig.workDurationRange)
                StepperControlRow(title: "休息时长", value: $store.breakDurationMinutes, range: ReminderConfig.breakDurationRange)
                StepperControlRow(title: "稍后提醒", value: $store.snoozeMinutes, range: ReminderConfig.snoozeRange)
            }

            SettingsSectionCard(title: "提示音") {
                Toggle("启用提示音", isOn: $store.soundEnabled)
                    .toggleStyle(SunsetToggleStyle())

                HStack(spacing: 12) {
                    Text("提示音类型")
                        .foregroundColor(.white.opacity(0.9))
                    Spacer(minLength: 20)
                    Picker("", selection: $store.soundOptionRawValue) {
                        ForEach(ReminderSoundOption.allCases, id: \.rawValue) { option in
                            Text(option.displayName).tag(option.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(width: 150)
                }

                HStack(spacing: 12) {
                    Text("音量")
                        .foregroundColor(.white.opacity(0.9))
                    Slider(value: $store.soundVolume, in: ReminderConfig.soundVolumeRange, step: 0.05)
                        .tint(Color.sunsetOrange)
                    Text("\(Int(store.soundVolume * 100))%")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.65))
                        .frame(width: 44, alignment: .trailing)
                }

                HStack {
                    Spacer()
                    Button("试听提示音") {
                        onPreviewSound()
                    }
                    .buttonStyle(SunsetGlowButtonStyle(isPrimary: false, accentColor: .neonCyan))
                    .frame(width: 150)
                }
            }

            SettingsSectionCard(title: "弹窗与通知") {
                Toggle("系统通知", isOn: $store.enableSystemNotification)
                    .toggleStyle(SunsetToggleStyle())
                Toggle("弹窗提醒", isOn: $store.enableOverlayPopup)
                    .toggleStyle(SunsetToggleStyle())
                Toggle("强制弹窗（置顶）", isOn: $store.forceBreakPopup)
                    .toggleStyle(SunsetToggleStyle())
            }
        }
        .font(DesignAssetLoader.shared.bodyFont(size: 13))
        .foregroundColor(.white.opacity(0.85))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 辅助组件

private struct SettingsSectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .foregroundColor(.sunsetOrange)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .textCase(.uppercase)
                .padding(.bottom, 2)

            content
        }
        .padding(14)
        .background(Color.bgCard.opacity(0.4))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

private struct StepperControlRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .foregroundColor(.white.opacity(0.9))
            Spacer(minLength: 20)
            Text("\(value) 分钟")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.sunsetOrange)
                .frame(width: 70, alignment: .trailing)
            Stepper("", value: $value, in: range)
                .labelsHidden()
                .frame(width: 84)
        }
    }
}

private struct SunsetToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            
            Button(action: { configuration.isOn.toggle() }) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(configuration.isOn ? Color.sunsetOrange.opacity(0.3) : Color.white.opacity(0.1))
                    .frame(width: 40, height: 20)
                    .overlay(
                        Circle()
                            .fill(configuration.isOn ? Color.sunsetOrange : Color.white.opacity(0.5))
                            .frame(width: 16, height: 16)
                            .shadow(color: configuration.isOn ? Color.sunsetOrange.opacity(0.5) : .clear, radius: 4)
                            .offset(x: configuration.isOn ? 8 : -8)
                    )
            }
            .buttonStyle(.plain)
            .animation(.easeOut(duration: 0.2), value: configuration.isOn)
        }
    }
}
