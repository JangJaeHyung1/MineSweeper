//
//  GameManager.swift
//  Minesweeper
//
//  Created by jh on 2/19/25.
//

import Foundation


enum Keys {
    static let totalMinesFound = "totalMinesFound"     // 총 지뢰 찾은 개수
    
    static let easyClearCount = "clearCountsEasy"     // Easy 모드 클리어 횟수
    static let normalClearCount = "clearCountsNormal" // Normal 모드 클리어 횟수
    static let hardClearCount = "clearCountsHard"     // Hard 모드 클리어 횟수
    
    static let easyBestClearTime = "easyBestClearTime"         // easy 최고 기록 (최단 시간)
    static let normalBestClearTime = "normalBestClearTime"         // normal 최고 기록 (최단 시간)
    static let hardBestClearTime = "hardBestClearTime"         // hard 최고 기록 (최단 시간)
    
    static let gachaCount = "totalDraws"               // 총 뽑기 횟수
    static let totalPoints = "totalPoints"             // 누적 포인트
    static let failGachaCount = "failDraws"            // 꽝 뽑은 횟수
}


class GameDataManager {
    static let shared = GameDataManager()
    private let defaults = UserDefaults.standard

    
    // ✅ 범용 데이터 저장 메서드 (재사용성 강화)
    private func saveDataAtDefaults(for key: String, value: Int) {
        if key == Keys.easyBestClearTime || key == Keys.normalBestClearTime || key == Keys.hardBestClearTime {
            let currentBest = defaults.integer(forKey: key)
            if currentBest == 0 || value < currentBest {
                defaults.set(value, forKey: key)
                print("✅ [\(key)] 새로운 최고 기록: \(value)")
            } else {
                print("ℹ️ [\(key)] 기존 기록 유지: \(currentBest)")
            }
        } else if key == Keys.totalPoints {
            let totalPoints = defaults.integer(forKey: key)
            let newPoints = totalPoints + value
            defaults.set(newPoints, forKey: key)
        } else if key == Keys.failGachaCount {
            let total = defaults.integer(forKey: key)
            let new = total + 1
            defaults.setValue(new, forKey: key)
        } else if key == Keys.easyClearCount || key == Keys.normalClearCount || key == Keys.hardClearCount {
            let total = defaults.integer(forKey: key)
            let new = total + 1
            defaults.setValue(new, forKey: key)
        } else if key == Keys.gachaCount {
            let total = defaults.integer(forKey: key)
            let new = total + 1
            defaults.setValue(new, forKey: key)
        } else if key == Keys.totalMinesFound {
            let total = defaults.integer(forKey: key)
            let new = total + value
            defaults.setValue(new, forKey: key)
        } else {
            defaults.set(value, forKey: key)
            print("✅ else [\(key)] \(value) 저장 완료!")
        }
    }
    

    // ✅ 데이터 저장과 Game Center 등록 통합
    func saveData(value: Int, key: String) {
        saveDataAtDefaults(for: key, value: value)
        LeaderboardViewModel.shared.submitScore(leaderboardID: key) // Game Center 등록
        let newValue = defaults.integer(forKey: key)
        print("✅ [\(key)] \(newValue) 저장 완료!")
    }

    // ✅ 데이터 불러오기
    func loadGameData() {
        print("""
        📊 저장된 기록:
        - 총 찾은 지뢰 개수: \(defaults.integer(forKey: Keys.totalMinesFound))
        - Easy 모드 클리어 횟수: \(defaults.integer(forKey: Keys.easyClearCount))
        - Normal 모드 클리어 횟수: \(defaults.integer(forKey: Keys.normalClearCount))
        - Hard 모드 클리어 횟수: \(defaults.integer(forKey: Keys.hardClearCount))
        - Easy 최고 기록: \(defaults.integer(forKey: Keys.easyBestClearTime))초
        - Normal 최고 기록: \(defaults.integer(forKey: Keys.normalBestClearTime))초
        - Hard 최고 기록: \(defaults.integer(forKey: Keys.hardBestClearTime))초
        - 뽑기 횟수: \(defaults.integer(forKey: Keys.gachaCount))
        - 누적 포인트: \(defaults.integer(forKey: Keys.totalPoints))
        - 꽝 뽑은 횟수: \(defaults.integer(forKey: Keys.failGachaCount))
        """)
    }
}
