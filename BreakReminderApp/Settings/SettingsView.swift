import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: SettingsStore

    var body: some View {
        Form {
            Section("时间设置") {
                Stepper(value: $store.workDurationMinutes, in: ReminderConfig.workDurationRange) {
                    Text("专注时长：\(store.workDurationMinutes) 分钟")
                }

                Stepper(value: $store.breakDurationMinutes, in: ReminderConfig.breakDurationRange) {
                    Text("休息时长：\(store.breakDurationMinutes) 分钟")
                }

                Stepper(value: $store.snoozeMinutes, in: ReminderConfig.snoozeRange) {
                    Text("稍后提醒：\(store.snoozeMinutes) 分钟")
                }
            }

            Section("提醒方式") {
                Toggle("系统通知", isOn: $store.enableSystemNotification)
                Toggle("强提醒弹窗", isOn: $store.enableOverlayPopup)
                Toggle("提示音", isOn: $store.soundEnabled)
            }
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 260)
    }
}
