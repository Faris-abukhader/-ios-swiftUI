//  audioManager.swift
//  answerIt
//  Created by admin on 2021/9/2.

import Foundation
import AVFoundation

class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    
    var audioPlayer: AVAudioPlayer?
    
    func play(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue) 
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.play()
        } catch let error {
            print("Sound Play Error -> \(error)")
        }
    }
}
