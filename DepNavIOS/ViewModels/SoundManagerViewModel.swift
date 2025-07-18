//
//  SoundManagerViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 14.07.2025.
//

import AVKit
import Foundation

class SoundManagerViewModel {
    static let instance = SoundManagerViewModel()

    var player: AVAudioPlayer?

    func playSound(sound: SoundOptions) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else {
            print("⚠️ Sound file not found in bundle")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

enum SoundOptions: String, CaseIterable {
    case doom = "doomSound"
}

// #Preview {
//    SoundManagerViewModel()
// }
