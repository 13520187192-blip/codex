import AppKit
import Foundation

final class SoundPlayer: SoundPlaying {
    private var activeSound: NSSound?

    func playReminder(option: ReminderSoundOption, volume: Double) {
        let names: [ReminderSoundOption: String] = [
            .glass: "Glass",
            .ping: "Ping",
            .pop: "Pop",
            .submarine: "Submarine"
        ]

        if let name = names[option], let sound = NSSound(named: NSSound.Name(name)) {
            activeSound = sound
            sound.volume = Float(ReminderConfig.clamp(volume, range: ReminderConfig.soundVolumeRange))
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}
