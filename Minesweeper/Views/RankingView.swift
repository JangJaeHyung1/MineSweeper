import SwiftUI
import GameKit


struct LeaderBoardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    @State private var totalMinesFound = 0
    @State private var clearCounts: [Difficulty: Int] = [
        .easy: 0, .normal: 0, .hard: 0
    ]
    @State private var bestTimes: [Difficulty: Int] = [
        .easy: 0, .normal: 0, .hard: 0
    ]
    @State private var totalDraws = 0
    @State private var totalPoints = 0
    @State private var failDraws = 0

    // ✅ Game Center 로그인 여부 및 랭킹 데이터
    @State private var leaderboardData: [String: (rank: Int, totalPlayers: Int)] = [:]
    @State private var isGameCenterConnected = false
    
    @State private var showGameCenterAlert = false // ✅ Alert 상태 변수
    @Environment(\.colorScheme) var colorScheme
    func colorForMode() -> Color {
        return colorScheme == .dark ? .white : .black
    }
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("\(NSLocalizedString("foundMine", comment: ""))").font(.title2).bold().foregroundColor(colorForMode())) {
                    StatisticRow(title: NSLocalizedString("totalMinesFound", comment: "총 찾은 지뢰 수"), value: "\(viewModel.totalMinesFound)", rankInfo: viewModel.leaderboardData[Keys.totalMinesFound], isRankVisible: viewModel.isGameCenterConnected)
                }

                Section(header: Text("\(NSLocalizedString("clearCount", comment: ""))").font(.title2).bold().foregroundColor(colorForMode())) {
                    ForEach(clearCounts.keys.sorted(), id: \.self) { mode in
                        if mode == Difficulty.easy {
                            StatisticRow(title: NSLocalizedString("easyClearCount", comment: "쉬운 모드 클리어 횟수"), value: "\(viewModel.clearCounts[mode] ?? 0)", rankInfo: viewModel.leaderboardData[Keys.easyClearCount], isRankVisible: viewModel.isGameCenterConnected)
                        } else if mode == Difficulty.normal {
                            StatisticRow(title: NSLocalizedString("normalClearCount", comment: "보통 모드 클리어 횟수"), value: "\(viewModel.clearCounts[mode] ?? 0)", rankInfo: viewModel.leaderboardData[Keys.normalClearCount], isRankVisible: viewModel.isGameCenterConnected)
                        } else {
                            StatisticRow(title: NSLocalizedString("hardClearCount", comment: "어려운 모드 클리어 횟수"), value: "\(viewModel.clearCounts[mode] ?? 0)", rankInfo: viewModel.leaderboardData[Keys.hardClearCount], isRankVisible: viewModel.isGameCenterConnected)
                        }
                        
                    }
                }

                Section(header: Text("\(NSLocalizedString("clearTimeFast", comment: ""))").font(.title2).bold().foregroundColor(colorForMode())) {
                    ForEach(bestTimes.keys.sorted(), id: \.self) { mode in
                        if mode == Difficulty.easy {
                            StatisticRow(title: NSLocalizedString("easyBestClearTime", comment: "쉬운 모드 최고 기록"), value: "\(viewModel.bestTimes[mode] ?? 0)", rankInfo: viewModel.leaderboardData[Keys.easyBestClearTime], isRankVisible: viewModel.isGameCenterConnected)
                        } else if mode == Difficulty.normal {
                            StatisticRow(title: NSLocalizedString("normalBestClearTime", comment: "보통 모드 최고 기록"), value: "\(viewModel.bestTimes[mode] ?? 0)", rankInfo: viewModel.leaderboardData[Keys.normalBestClearTime], isRankVisible: viewModel.isGameCenterConnected)
                        } else {
                            StatisticRow(title: NSLocalizedString("hardBestClearTime", comment: "어려운 모드 최고 기록"), value: "\(viewModel.bestTimes[mode] ?? 0)", rankInfo: viewModel.leaderboardData[Keys.hardBestClearTime], isRankVisible: viewModel.isGameCenterConnected)
                        }
                        
                    }
                }

                Section(header: Text("\(NSLocalizedString("drawCount", comment: ""))").font(.title2).bold().foregroundColor(colorForMode())) {
                    StatisticRow(title: NSLocalizedString("totalDraws", comment: "총 뽑기 횟수"), value: "\(viewModel.totalDraws)", rankInfo: viewModel.leaderboardData["totalDraws"], isRankVisible: viewModel.isGameCenterConnected)
                    StatisticRow(title: NSLocalizedString("totalPoints", comment: "누적 포인트"), value: "\(viewModel.totalPoints)", rankInfo: viewModel.leaderboardData["totalPoints"], isRankVisible: viewModel.isGameCenterConnected)
                    StatisticRow(title: NSLocalizedString("failDraws", comment: "꽝 뽑은 횟수"), value: "\(viewModel.failDraws)", rankInfo: viewModel.leaderboardData["failDraws"], isRankVisible: viewModel.isGameCenterConnected)
                }

                Section {
                    Button(action: {
                        viewModel.openGameCenter()
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill").foregroundColor(.yellow)
                            Text("\(NSLocalizedString("viewRank", comment: ""))")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }.padding()
                }
            }
            .navigationTitle("\(NSLocalizedString("gameStatic", comment: ""))")
        }
        .onAppear {
            viewModel.authenticateGameCenter()
        }.alert(isPresented: $showGameCenterAlert) {
            Alert(title: Text("\(NSLocalizedString("gameCenterConnected", comment: ""))"), message: Text(""), dismissButton: .default(Text("\(NSLocalizedString("ok", comment: ""))")))
        }
    }
    
    

        
}

// ✅ 개별 통계 표시 컴포넌트 (Game Center 연동 여부 반영)
struct StatisticRow: View {
    let title: String
    let value: String
    let rankInfo: (rank: Int, totalPlayers: Int)?
    let isRankVisible: Bool

    var body: some View {
        HStack(alignment: .center) { // ✅ HStack 정렬을 .center로 설정
            VStack(alignment: .leading) {
                Text(title)
                if isRankVisible, let rankInfo = rankInfo {
                    VStack(alignment: .leading) {
                        ForEach([
                            "\(rankInfo.rank) / \(rankInfo.totalPlayers)"
                        ], id: \.self) { text in
                            Text(text)
                        }
                        .padding(.leading, 10) // ✅ 전체 VStack 왼쪽 패딩 추가
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(value)
                .font(.title3)
                .bold()
                .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] } // ✅ 강제 중앙 정렬
        }
        .padding(.vertical, 5)
    }
}
