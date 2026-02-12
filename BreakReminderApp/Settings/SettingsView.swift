import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    var onPreviewSound: () -> Void

    var body: some View {
        GroupBox("提醒设置") {
            Form {
                Section("时间设置") {
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
                }

                Section("弹窗与通知") {
                    Toggle("系统通知", isOn: $store.enableSystemNotification)
                    Toggle("弹窗提醒", isOn: $store.enableOverlayPopup)
                    Toggle("强制弹窗（置顶）", isOn: $store.forceBreakPopup)
                }
            }
        }
    }
}
