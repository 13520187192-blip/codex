import AppKit
import Foundation

#if canImport(Sparkle)
import Sparkle

final class UpdaterController: NSObject, Updating {
    private let updaterController: SPUStandardUpdaterController

    override init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        super.init()
    }

    func checkForUpdatesInBackground() {
        updaterController.updater.checkForUpdatesInBackground()
    }

    func checkForUpdatesManually() {
        updaterController.checkForUpdates(nil)
    }
}
#else
final class UpdaterController: Updating {
    private let releasesURL: URL

    init(releasesURL: URL? = URL(string: "https://github.com/13520187192-blip/codex/releases")) {
        self.releasesURL = releasesURL ?? URL(string: "https://github.com/13520187192-blip/codex/releases")!
    }

    func checkForUpdatesInBackground() {
        // Fallback path when Sparkle is not linked in the build.
    }

    func checkForUpdatesManually() {
        NSWorkspace.shared.open(releasesURL)
    }
}
#endif
