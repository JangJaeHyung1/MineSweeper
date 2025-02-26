//
//  LeaderboardViewModel.swift
//  Minesweeper
//
//  Created by jh on 2/19/25.
//

import GameKit

class LeaderboardViewModel: ObservableObject {
    static let shared = LeaderboardViewModel()
    @Published var leaderboardData: [String: (rank: Int, totalPlayers: Int)] = [:]
    @Published var isGameCenterConnected = GKLocalPlayer.local.isAuthenticated
    @Published var showGameCenterAlert = false
    
    @Published var totalMinesFound: Int = 0
    @Published var clearCounts: [Difficulty: Int] = [
        .easy: 0, .normal: 0, .hard: 0
    ]
    @Published var bestTimes: [Difficulty: Int] = [
        .easy: 0, .normal: 0, .hard: 0
    ]
    @Published var totalDraws = 0
    @Published var totalPoints = 0
    @Published var failDraws = 0
    
    init() {
        self.totalMinesFound = UserDefaults.standard.integer(forKey: Keys.totalMinesFound)
        self.clearCounts[.easy] = UserDefaults.standard.integer(forKey: Keys.easyClearCount)
        self.clearCounts[.normal] = UserDefaults.standard.integer(forKey: Keys.normalClearCount)
        self.clearCounts[.hard] = UserDefaults.standard.integer(forKey: Keys.hardClearCount)
        self.bestTimes[.easy] = UserDefaults.standard.integer(forKey: Keys.easyBestClearTime)
        self.bestTimes[.normal] = UserDefaults.standard.integer(forKey: Keys.normalBestClearTime)
        self.bestTimes[.hard] = UserDefaults.standard.integer(forKey: Keys.hardBestClearTime)
        self.totalDraws = UserDefaults.standard.integer(forKey: Keys.gachaCount)
        self.totalPoints = UserDefaults.standard.integer(forKey: Keys.totalPoints)
        self.failDraws = UserDefaults.standard.integer(forKey: Keys.failGachaCount)
        
    }
    // ✅ 리더보드 ID 설정
    private let leaderboardKeys: [String] = [
        Keys.totalMinesFound, Keys.easyClearCount,
        Keys.normalClearCount, Keys.hardClearCount, Keys.easyBestClearTime, Keys.normalBestClearTime, Keys.hardBestClearTime, Keys.gachaCount, Keys.totalPoints, Keys.failGachaCount
    ]

    
    // ✅ 점수 등록 (UserDefaults와 Game Center 동기화)
    func submitScore(leaderboardID: String) {
        let value = UserDefaults.standard.integer(forKey: leaderboardID)
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score]) { error in
            if let error = error {
                print("❌ [\(leaderboardID)] 점수 등록 실패: \(error.localizedDescription)")
            } else {
                print("✅ [\(leaderboardID)] \(value)점 등록 완료!")
            }
        }
    }
    
    // ✅ Game Center 리더보드 열기
    func openGameCenter() {
        if !isGameCenterConnected {
            authenticateGameCenter()
            return
        }
        print("openGameCenter isGameCenterConnected:\(isGameCenterConnected)")
        let localPlayer = GKLocalPlayer.local
        if !localPlayer.isAuthenticated {
            showGameCenterAlert = true
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                if rootVC.presentedViewController == nil { // ✅ 중복 실행 방지
                    let gcVC = GKGameCenterViewController()
                    gcVC.gameCenterDelegate = rootVC as? GKGameCenterControllerDelegate
                    gcVC.viewState = .leaderboards
                    rootVC.present(gcVC, animated: true, completion: nil)
                } else {
                    showGameCenterAlert = true
                    isGameCenterConnected = true
                    self.loadLeaderboardData()
                }
            }
        }
    }
    
    // ✅ Game Center 로그인
        func authenticateGameCenter() {
            GKLocalPlayer.local.authenticateHandler = { viewController, error in
                if let viewController = viewController {
                    DispatchQueue.main.async {
                        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                            rootVC.present(viewController, animated: true)
                        }
                    }
                } else if GKLocalPlayer.local.isAuthenticated {
                    DispatchQueue.main.async {
                        self.isGameCenterConnected = true
                        print("✅ Game Center 로그인 성공")
                        self.loadLeaderboardData()  // 로그인 성공 시 랭킹 불러오기
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isGameCenterConnected = false
                        print("🚫 Game Center 인증 실패")
                    }
                }
            }
        }
    
    func loadLeaderboardData() {
        let leaderboardIDs = leaderboardKeys
        
        for id in leaderboardIDs {
            fetchLeaderboardRank(for: id)
        }
    }
    
    func fetchLeaderboardRank(for leaderboardID: String) {
        let leaderboard = GKLeaderboard()
        leaderboard.identifier = leaderboardID
        leaderboard.timeScope = .allTime
        
        leaderboard.loadScores { scores, error in
            if let error = error {
                print("❌ [\(leaderboardID)] 리더보드 데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            let rank = leaderboard.localPlayerScore?.rank ?? 0
            let totalPlayers = leaderboard.maxRange
            DispatchQueue.main.async {
                self.leaderboardData[leaderboardID] = (rank, totalPlayers)
                print("✅ [\(leaderboardID)] 순위: \(rank)등 / 전체: \(totalPlayers)명")
            }
        }
    }
}
