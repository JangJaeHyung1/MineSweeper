//
//  MineSweeperView.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI

// MARK: - Game View
struct MineSweeperView: View {
    @StateObject private var viewModel = MineSweeperViewModel()
    @State private var selectedDifficulty: String = "normal"
    @State private var showWinAlert: Bool = false
    @State private var elapsedTime: Int = 0
    @State private var timerRunning: Bool = false
    @State private var gameOver: Bool = false
    @State private var timer: Timer? = nil
    @State private var showDifficultySheet: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showGachaSheet = false
    @State private var newItem: String? = nil
    @State private var showGameOverPopup = false
    @State private var touchStartTime: Date?
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
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
                BannerAdView(adUnitID: adUnitID)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
            HStack {
                Text("⏱️\(elapsedTime)")
                    .fontWeight(.bold)
                    .frame(width: 75, alignment: .leading) // 고정 너비 및 오른쪽 정렬
                    .monospacedDigit() // 숫자 폭 고정
                Text("💣 \(max(viewModel.mineCount - viewModel.flagsPlaced,0))")
                    .fontWeight(.bold)
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
                    ActionSheet(title: Text("select_difficulty"), buttons: [
                        .default(Text("easy")) {
                            selectedDifficulty = "easy"
                            viewModel.setDifficulty(level: "easy")
                            resetGame()
                        },
                        .default(Text("normal")) {
                            selectedDifficulty = "normal"
                            viewModel.setDifficulty(level: "normal")
                            resetGame()
                        },
                        .default(Text("hard")) {
                            selectedDifficulty = "hard"
                            viewModel.setDifficulty(level: "hard")
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
                                    .onChanged { _ in
                                        if !gameOver {
                                            if touchStartTime == nil {
                                                touchStartTime = Date()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    if let start = touchStartTime, Date().timeIntervalSince(start) >= 0.3 {
                                                        // 🏳️ 깃발 꽂기
                                                        Haptic.impact(style: .medium)
                                                        viewModel.toggleFlag(row: row, col: col)
                                                        touchStartTime = nil // 중복 방지
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        if !gameOver {
                                            guard let startTime = touchStartTime else { return }
                                            let duration = Date().timeIntervalSince(startTime)
                                            touchStartTime = nil
                                            
                                            if duration < 0.4 {
                                                // 🚩 셀 열기
                                                handleCellTap(row: row, col: col)
                                            }
                                            
                                            if viewModel.checkForWin() {
                                                handleWin()
                                            }
                                        }
                                    }
                            )
//                            .onTapGesture {
//                                if !gameOver {
//                                    handleCellTap(row: row, col: col)
//                                }
//                            }
//                            .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 10) {
//                                if !gameOver {
//                                    DispatchQueue.main.async {
//                                        Haptic.impact(style: .medium)
//                                    }
//                                    viewModel.toggleFlag(row: row, col: col)
//                                    if viewModel.checkForWin() {
//                                        handleWin()
//                                    }
//                                }
//                            }
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
        }
        .sheet(isPresented: $showGachaSheet) {
            GachaView(viewModel: viewModel, newItem: $newItem)
        }
        .alert(isPresented: Binding<Bool>(
            get: { showWinAlert || showGameOverPopup },
            set: { _ in
                showWinAlert = false
                showGameOverPopup = false
            }
        )) {
            if showWinAlert {
                return Alert(
                    title: Text("congratulations"),
                    message: Text("You've found all the mines! Time taken: \(elapsedTime) seconds"),
                    dismissButton: .default(Text("ok")) {
                        resetGame()
                    }
                )
            } else {
                return Alert(
                    title: Text(""),
                    message: Text("Better luck next time!"),
                    dismissButton: .default(Text("new_game")) {
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
        if selectedDifficulty == "easy" {
            viewModel.addPoints(15)
            print("easy win")
        } else if selectedDifficulty == "normal" {
            viewModel.addPoints(20)
            print("normal win")
        } else {
            viewModel.addPoints(25)
            print("hard win")
        }
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
