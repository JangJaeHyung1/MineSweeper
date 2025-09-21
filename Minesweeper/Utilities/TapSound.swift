//
//  TapSound.swift
//  Minesweeper
//
//  Created by jh on 9/21/25.
//

import AudioToolbox
import AVFoundation

struct Sound {
    private static var flagPlayer: AVAudioPlayer?
    private static var popPlayer: AVAudioPlayer?
    private static var tapPlayer: AVAudioPlayer?
    private static var sfxVolumeLinear: Float = 0.8
    
    static func preloadSound() {
        preloadTap()
        preloadFlag()
        preloadPop()
    }
    static func preloadTap() {
        guard tapPlayer == nil else { return }
        if let url = Bundle.main.url(forResource: "tap", withExtension: "mp3") {
            tapPlayer = try? AVAudioPlayer(contentsOf: url)
            tapPlayer?.prepareToPlay()
        }
    }
    
    static func preloadFlag() {
        guard flagPlayer == nil else { return }
        if let url = Bundle.main.url(forResource: "flag", withExtension: "mp3") {
            flagPlayer = try? AVAudioPlayer(contentsOf: url)
            flagPlayer?.prepareToPlay()
            flagPlayer?.volume = sfxVolumeLinear
        }
    }
    
    static func preloadPop() {
        guard popPlayer == nil else { return }
        if let url = Bundle.main.url(forResource: "pop", withExtension: "mp3") {
            popPlayer = try? AVAudioPlayer(contentsOf: url)
            popPlayer?.prepareToPlay()
        }
    }
    
    /// Set global SFX volume in decibels (typical range -60dB ... 0dB). 0dB = 100%.
    static func setVolume(dB: Float) {
        // Clamp to a safe range to avoid extreme values
        let clamped = max(-60.0, min(0.0, dB))
        sfxVolumeLinear = pow(10.0, clamped / 20.0)
        applyVolume()
    }

    /// Set global SFX volume using linear amplitude (0.0 ~ 1.0).
    static func setVolumeLinear(_ value: Float) {
        sfxVolumeLinear = max(0.0, min(1.0, value))
        applyVolume()
    }

    /// Apply volume to all loaded players.
    private static func applyVolume() {
        flagPlayer?.volume = sfxVolumeLinear
    }


    static func flag() {
        if let p = flagPlayer {
            p.volume = sfxVolumeLinear
            p.currentTime = 0
            p.play()
        } else {
            AudioServicesPlaySystemSound(1104) // 폴백
        }
    }
    
    static func pop() {
        if let p = popPlayer {
            p.currentTime = 0
            p.play()
        } else {
            AudioServicesPlaySystemSound(1104) // 폴백
        }
    }

    static func tap() {
        if let p = tapPlayer {
            p.currentTime = 0
            p.play()
        } else {
            AudioServicesPlaySystemSound(1104) // 폴백
        }
    }
}

@MainActor
final class AppBootstrap {
    static func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        try? session.setActive(true, options: [])
    }
}
