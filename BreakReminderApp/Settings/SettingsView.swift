import AppKit
import SwiftUI

struct SettingsWindowView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var appeared = false

    private let assetLoader = DesignAssetLoader.shared

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(alignment: .leading, spacing: 18) {
                header
                Text(viewModel.statusLine)
                    .font(assetLoader.bodyFont(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                SettingsPanelView(store: viewModel.settingsStore) {
                    viewModel.playPreviewSound()
                }

                HStack(spacing: 10) {
                    Button("检查更新") {
                        viewModel.checkForUpdatesNow()
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    Spacer()

                    Button("关闭窗口") {
                        viewModel.closeWindow()
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .padding(20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.28), value: appeared)
        }
        .frame(minWidth: 820, minHeight: 640)
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            if let icon = assetLoader.image(named: "icon_clock") {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Image(systemName: "clock.badge")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("休息提醒设置")
                    .font(assetLoader.titleFont(size: 30))
                Text("窗口可关闭，应用会继续在菜单栏运行")
                    .font(assetLoader.bodyFont(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let hero = assetLoader.image(named: "hero") {
                Image(nsImage: hero)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 72)
                    .opacity(0.92)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.96, blue: 0.99), Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if let pattern = assetLoader.image(named: "bg_pattern") {
                Image(nsImage: pattern)
                    .resizable(resizingMode: .tile)
                    .opacity(0.14)
                    .ignoresSafeArea()
            }
        }
    }
}

struct SettingsPanelView: View {
    @ObservedObject var store: SettingsStore
    var onPreviewSound: () -> Void

    var body: some View {
        GroupBox("提醒参数") {
            Form {
                Section("时间设置（1~60 分钟）") {
                    Stepper(value: $store.workDurationMinutes, in: ReminderConfig.workDurationRange) {
                        Text("提醒间隔：\(store.workDurationMinutes) 分钟")
                    }

                    Stepper(value: $store.breakDurationMinutes, in: ReminderConfig.breakDurationRange) {
                        Text("休息时长：\(store.breakDurationMinutes) 分钟")
                    }

                    Stepper(value: $store.snoozeMinutes, in: ReminderConfig.snoozeRange) {
                        Text("稍后提醒：\(store.snoozeMinutes) 分钟")
                    }
                }

                Section("提示音") {
                    Toggle("启用提示音", isOn: $store.soundEnabled)

                    Picker("提示音类型", selection: $store.soundOptionRawValue) {
                        ForEach(ReminderSoundOption.allCases, id: \.rawValue) { option in
                            Text(option.displayName).tag(option.rawValue)
                        }
                    }

                    HStack {
                        Text("音量")
                        Slider(value: $store.soundVolume, in: ReminderConfig.soundVolumeRange, step: 0.05)
                        Text("\(Int(store.soundVolume * 100))%")
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }

                    Button("试听提示音") {
                        onPreviewSound()
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }

                Section("弹窗与通知") {
                    Toggle("系统通知", isOn: $store.enableSystemNotification)
                    Toggle("弹窗提醒", isOn: $store.enableOverlayPopup)
                    Toggle("强制弹窗（置顶）", isOn: $store.forceBreakPopup)
                }
            }
            .font(DesignAssetLoader.shared.bodyFont(size: 13))
        }
    }
}
