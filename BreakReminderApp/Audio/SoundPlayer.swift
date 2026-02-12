import AppKit
import Foundation

final class SoundPlayer: SoundPlaying {
    private var activeSound: NSSound?

    func playReminder() {
        if let url = Bundle.main.url(forResource: "reminder", withExtension: "aiff"),
           let sound = NSSound(contentsOf: url, byReference: false) {
            activeSound = sound
            sound.play()
            return
        }

        NSSound.beep()
    }
}
