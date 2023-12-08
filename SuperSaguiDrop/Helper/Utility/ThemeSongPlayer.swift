//
//  ThemeSongPlayer.swift
//  SuperSaguiDrop
//
//  Created by Sam Hodak on 12/8/23.
//

import Foundation
import AVFoundation

class ThemeSongPlayer {
    static var themeSongName = "Randy Sharp - Jungle Boogie Woogie"
    var audioPlayer: AVAudioPlayer?
    
    init() {
        guard let path = Bundle.main.path(
            forResource: ThemeSongPlayer.themeSongName,
            ofType: "mp3") else
        {
            print("Audio file not found")
            return
        }
        
        do {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
    func start() {
        guard let audioPlayer = audioPlayer else {
            print("Theme song player not ready")
            return
        }
        
        audioPlayer.play()
    }
    
    func stop() {
        guard let audioPlayer = audioPlayer else {
            print("Theme song player not ready")
            return
        }
        
        audioPlayer.stop()
    }
}
