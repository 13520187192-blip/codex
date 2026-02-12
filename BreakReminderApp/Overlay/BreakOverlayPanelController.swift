import AppKit
import SwiftUI

final class BreakOverlayPanelController: BreakOverlayPresenting {
    private var panel: NSPanel?

    func showBreakDue(forceBreakPopup: Bool, onStartBreak: @escaping () -> Void, onSnooze: @escaping () -> Void, onSkip: @escaping () -> Void) {
        let contentView = BreakOverlayView(
            onStartBreak: {
                onStartBreak()
            },
            onSnooze: {
                onSnooze()
            },
            onSkip: {
                onSkip()
            }
        )

        if panel == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 220),
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

private struct BreakOverlayView: View {
    let onStartBreak: () -> Void
    let onSnooze: () -> Void
    let onSkip: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 16) {
            Text("该休息了")
                .font(.system(size: 26, weight: .bold))

            Text("离开屏幕几分钟，活动一下身体。")
                .font(.body)
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                Button("开始休息") {
                    onStartBreak()
                }
                .keyboardShortcut(.defaultAction)

                Button("稍后提醒") {
                    onSnooze()
                }

                Button("跳过本次") {
                    onSkip()
                }
            }
        }
        .padding(20)
        .frame(width: 380, height: 220)
        .scaleEffect(appeared ? 1 : 0.94)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            appeared = true
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: appeared)
    }
}
