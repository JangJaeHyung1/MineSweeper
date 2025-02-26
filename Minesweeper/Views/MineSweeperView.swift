//
//  MineSweeperView.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI


enum Difficulty: CaseIterable, Comparable {
    case easy
    case normal
    case hard
    // ✅ 정렬 기준 (easy → normal → hard 순)
    static func < (lhs: Difficulty, rhs: Difficulty) -> Bool {
        let order: [Difficulty] = [.easy, .normal, .hard]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
    // 난이도별 포인트 반환
    var rewardPoints: Int {
        switch self {
        case .easy: return 10
        case .normal: return 20
        case .hard: return 40
        }
    }

    // 난이도별 지뢰 수 및 높이 설정
    var gridSettings: (height: Int, mines: Int) {
        switch self {
        case .easy: return (height: 8, mines: 8)
        case .normal:
            return (height: 11, mines: 12)
        case .hard:
            if DeviceUtils.hasNotch {
//                return (height: 14, mines: 23)
                return (height: 15, mines: 23)
            } else {
                return (height: 12, mines: 19)
            }
        }
    }
}

// MARK: - Game View
struct MineSweeperView: View {
    @StateObject private var viewModel = MineSweeperViewModel()
    @State private var selectedDifficulty: Difficulty = .normal
    @State private var showWinAlert: Bool = false
    @State private var elapsedTime: Int = 0
    @State private var timerRunning: Bool = false
    @State private var gameOver: Bool = false
    @State private var timer: Timer? = nil
    @State private var showDifficultySheet: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showGachaSheet = false
    @State private var showRankingSheet = false
    
    @State private var newItem: String? = nil
    @State private var showGameOverPopup = false
    @State private var touchStartTime: Date?
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var hasWon = false
    
    var adUnitID: String {
        Bundle.main.object(forInfoDictionaryKey: "GADAdUnitID") as? String ?? ""
    }
    func colorForMode() -> Color {
        return colorScheme == .dark ? .white : .black
    }
    
    private func toggleAppearance() {
        isDarkMode.toggle()
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }

    var body: some View {
       
        let screenWidth = UIScreen.main.bounds.width
        let cellSize = (screenWidth / CGFloat(viewModel.gridWidthSize)) - 6
        let spacing: CGFloat = 2

        VStack(spacing: 0) {
            Spacer().frame(height: 0) // 상단 여백 강제 제거
//                BannerAdView(adUnitID: adUnitID)
//                    .frame(height: 50)
//                    .background(Color(UIColor.systemGray6))
            HStack {
                Button(action: {
                    showRankingSheet = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemGray6).opacity(0.6))
                            .frame(width: 85, height: 40)
                        Text("⏱️\(elapsedTime)")
                            .fontWeight(.bold)
                            .tint(colorForMode())
                            .frame(width: 80, alignment: .leading) // 고정 너비 및 오른쪽 정렬
                            .monospacedDigit() // 숫자 폭 고정
                        }
                }
                .actionSheet(isPresented: $showDifficultySheet) {
                    ActionSheet(title: Text("\(NSLocalizedString("select_difficulty", comment: ""))"), buttons: [
                        .default(Text("\(NSLocalizedString("easy", comment: ""))")) {
                            selectedDifficulty = .easy
                            viewModel.setDifficulty(.easy)
                            resetGame()
                        },
                        .default(Text("\(NSLocalizedString("normal", comment: ""))")) {
                            selectedDifficulty = .normal
                            viewModel.setDifficulty(.normal)
                            resetGame()
                        },
                        .default(Text("\(NSLocalizedString("hard", comment: ""))")) {
                            selectedDifficulty = .hard
                            viewModel.setDifficulty(.hard)
                            resetGame()
                        },
                        .default(Text(isDarkMode ? "☀️" : "🌙")) {
                            toggleAppearance()
                        },
                        .cancel()
                    ])
                }
                
                Text("💣 \(max(viewModel.mineCount - viewModel.flagsPlaced,0))")
                    .fontWeight(.bold)
                    .onLongPressGesture(minimumDuration: 2.0) {
                        if UserDefaults.standard.bool(forKey: viewModel.hiddenBonusPoint) == false {
                            viewModel.isHiddenBonusAlert = true
                        }
                        print("✅ 3초 터치 완료! hiddenBonusPoint 활성화")
                    }
                
                Spacer()
                Text("🏆 \(viewModel.points)")
                    .font(.headline)
                    .foregroundColor(.purple)
                    .onTapGesture {
                        showGachaSheet = true
                    }
                Spacer()
                Button(action: {
                    showDifficultySheet = true
                }) {
                    ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray6).opacity(0.6))
                                .frame(width: 40, height: 40)
                            
                            Text("🕹️")
                                .font(.title)
                        }
                }
                .actionSheet(isPresented: $showDifficultySheet) {
                    ActionSheet(title: Text("\(NSLocalizedString("select_difficulty", comment: ""))"), buttons: [
                        .default(Text("\(NSLocalizedString("easy", comment: ""))")) {
                            selectedDifficulty = .easy
                            viewModel.setDifficulty(.easy)
                            resetGame()
                        },
                        .default(Text("\(NSLocalizedString("normal", comment: ""))")) {
                            selectedDifficulty = .normal
                            viewModel.setDifficulty(.normal)
                            resetGame()
                        },
                        .default(Text("\(NSLocalizedString("hard", comment: ""))")) {
                            selectedDifficulty = .hard
                            viewModel.setDifficulty(.hard)
                            resetGame()
                        },
                        .default(Text(isDarkMode ? "☀️" : "🌙")) {
                            toggleAppearance()
                        },
                        .cancel()
                    ])
                }
            }
            .padding()

            Spacer()
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: viewModel.gridWidthSize),
                spacing: spacing
            ) {
                ForEach(0..<viewModel.gridHeightSize, id: \ .self) { row in
                    ForEach(0..<viewModel.gridWidthSize, id: \ .self) { col in
                        CellView(cell: viewModel.grid[row][col], cellSize: cellSize, flag: viewModel.selectedFlag)
                            .id("\(row)-\(col)")
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if !gameOver {
                                            if touchStartTime == nil {
                                                touchStartTime = Date()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    if let start = touchStartTime, Date().timeIntervalSince(start) >= 0.3 {
                                                        // 🏳️ 깃발 꽂기
                                                        Haptic.impact(style: .medium)
                                                        viewModel.toggleFlag(row: row, col: col)
                                                        if viewModel.checkForWin() {
                                                            handleWin()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        if !gameOver {
                                            guard let startTime = touchStartTime else { return }
                                            let duration = Date().timeIntervalSince(startTime)
                                            touchStartTime = nil
                                            let dragDistance = abs(value.translation.width) + abs(value.translation.height)
                                            if dragDistance < 10, touchStartTime == nil {
                                                if duration < 0.3 {
                                                    // 🚩 셀 열기
                                                    handleCellTap(row: row, col: col)
                                                }
                                                if viewModel.checkForWin() {
                                                    handleWin()
                                                }
                                            }
                                            
                                        }
                                    }
                            )
                    }
                }
            }
            .frame(height: CGFloat(10) * cellSize + CGFloat(9) * spacing) // 최대 높이 고정
            .padding()
            Spacer()
        }
        .onAppear {
            isDarkMode = colorScheme == .dark
            startTimer()
            GameDataManager.shared.loadGameData()
        }
        .sheet(isPresented: $showGachaSheet) {
            GachaView(viewModel: viewModel, newItem: $newItem)
        }
        .sheet(isPresented: $showRankingSheet) {
            LeaderBoardView()
        }
        .alert(isPresented: Binding<Bool>(
            get: { showWinAlert || showGameOverPopup || viewModel.isHiddenBonusAlert },
            set: { _ in
                showWinAlert = false
                showGameOverPopup = false
                viewModel.isHiddenBonusAlert = false
            }
        )) {
            if showWinAlert {
                return Alert(
                    title: Text("\(NSLocalizedString("congratulations", comment: ""))"),
                    message: Text(String(format: NSLocalizedString("clearTime", comment: ""), elapsedTime)),
                    dismissButton: .default(Text("\(NSLocalizedString("ok", comment: ""))")) {
                        resetGame()
                    }
                )
            } else if viewModel.isHiddenBonusAlert {
                return Alert(
                    title: Text("\(NSLocalizedString("congratulations", comment: ""))"),
                    message: Text("\(NSLocalizedString("hiddenPoints", comment: ""))"),
                    dismissButton: .default(Text("\(NSLocalizedString("ok", comment: ""))")) {
                        viewModel.hiddenPoint()
                        viewModel.isHiddenBonusAlert = false
                    }
                )
            } else {
                return Alert(
                    title: Text(""),
                    message: Text("\(NSLocalizedString("BetterlucknextTime", comment: ""))"),
                    dismissButton: .default(Text("\(NSLocalizedString("new_game", comment: ""))")) {
                        resetGame()
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
    }

    func handleCellTap(row: Int, col: Int) {
        viewModel.revealCell(row: row, col: col)
        if viewModel.grid[row][col].isMine && !viewModel.grid[row][col].isFlagged {
            handleGameOver()
        } else if viewModel.checkForWin() {
            handleWin()
        }
    }

    func handleWin() {
        guard !hasWon else { return } // 중복 호출 방지
        hasWon = true
        
        let points = viewModel.currentDifficulty.rewardPoints
        if viewModel.currentDifficulty == .easy {
            GameDataManager.shared.saveData(value: elapsedTime, key: Keys.easyBestClearTime)
        } else if viewModel.currentDifficulty == .normal {
            GameDataManager.shared.saveData(value: elapsedTime, key: Keys.normalBestClearTime)
        } else {
            GameDataManager.shared.saveData(value: elapsedTime, key: Keys.hardBestClearTime)
        }
        
        
        viewModel.addPoints(points)
        gameOver = true
        showWinAlert = true
        timerRunning = false
        timer?.invalidate()
    }

    func handleGameOver() {
        gameOver = true
        timerRunning = false
        timer?.invalidate()
        showGameOverPopup = true
        
        // 💣 모든 지뢰 공개
        for row in 0..<viewModel.gridHeightSize {
            for col in 0..<viewModel.gridWidthSize {
                if viewModel.grid[row][col].isMine {
                    viewModel.grid[row][col].isRevealed = true
                }
            }
        }
        
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                Haptic.impact(style: .heavy)
            }
        }
    }

    func resetGame() {
        hasWon = false
        gameOver = false
        showWinAlert = false
        elapsedTime = 0
        viewModel.resetGame()
        startTimer()
    }

    func startTimer() {
        timerRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerRunning {
                elapsedTime += 1
                if elapsedTime > 999 {
                    elapsedTime = 999
                }
            } else {
                timer?.invalidate()
            }
        }
    }
}
