import Foundation
import UserNotifications

final class NotificationService: NotificationServicing {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func showBreakDueNotification() {
        let content = UNMutableNotificationContent()
        content.title = "休息提醒"
        content.body = "你已经专注一段时间了，该休息一下。"
        content.sound = nil

        let request = UNNotificationRequest(
            identifier: "break_due_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        center.add(request)
    }

    func showBreakStartedNotification(durationMinutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "开始休息"
        content.body = "本次休息建议时长 \(durationMinutes) 分钟。"
        content.sound = nil

        let request = UNNotificationRequest(
            identifier: "break_started_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        center.add(request)
    }
}
