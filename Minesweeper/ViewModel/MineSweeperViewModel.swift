//
//  MineSweeperViewModel.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI
import AudioToolbox
import AVFoundation

struct Sound {
    private static var flagPlayer: AVAudioPlayer?
    private static var popPlayer: AVAudioPlayer?
    private static var sfxVolumeLinear: Float = 0.6
    
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
        AudioServicesPlaySystemSound(1104)
    }
}
// MARK: - ViewModel
class MineSweeperViewModel: ObservableObject {
    @Published var grid: [[Cell]] = []
    @Published var gridWidthSize: Int = 8
    @Published var gridHeightSize: Int = Difficulty.normal.gridSettings.height
    @Published var mineCount: Int = Difficulty.normal.gridSettings.mines
    @Published var flagsPlaced: Int = 0
    @Published var points: Int = 0
    @Published var selectedFlag: String = "🚩" // 기본 플래그
    @Published var availableFlags: [String] = ["🚩"]
    @Published var currentDifficulty: Difficulty = .normal
    @Published var isHiddenBonusAlert = false
    private let pointsKey = "userPoints"
    private let flagsKey = "userFlags"
    private let usedFlagKey = "usedFlag"
    let hiddenBonusPoint = "hiddenBonusPoint"
    init() {
        loadUsedFlag()
        loadPoints()
        loadFlags()
        resetGame()
        Sound.preloadFlag()
        Sound.preloadPop()
    }

    func addPoints(_ amount: Int) {
        points += amount
        savePoints()
        GameDataManager.shared.saveData(value: amount, key: Keys.totalPoints)
        GameDataManager.shared.saveData(value: currentDifficulty.gridSettings.mines, key: Keys.totalMinesFound)
        if currentDifficulty == .easy {
            GameDataManager.shared.saveData(value: 1, key: Keys.easyClearCount)
        } else if currentDifficulty == .normal {
            GameDataManager.shared.saveData(value: 1, key: Keys.normalClearCount)
        } else {
            GameDataManager.shared.saveData(value: 1, key: Keys.hardClearCount)
        }
    }
    
    func hiddenPoint() {
        if UserDefaults.standard.bool(forKey: hiddenBonusPoint) == false {
            UserDefaults.standard.setValue(true, forKey: hiddenBonusPoint)
            points += 1000
            savePoints()
            isHiddenBonusAlert = true
        }
        
    }
    
    func deductPoints(_ amount: Int) -> Bool {
        if points >= amount {
            points -= amount
            GameDataManager.shared.saveData(value: 1, key: Keys.gachaCount)
            savePoints()
            return true
        }
        return false
    }
    private func savePoints() {
        UserDefaults.standard.set(points, forKey: pointsKey)
    }
    
    private func loadPoints() {
//        points = 5000
        points = UserDefaults.standard.integer(forKey: pointsKey)
    }
    
    func addFlag(_ flag: String) {
        if !availableFlags.contains(flag) {
            availableFlags.append(flag)
            saveFlags()
        }
    }
    
    private func saveFlags() {
        UserDefaults.standard.set(availableFlags, forKey: flagsKey)
    }
    
    private func loadFlags() {
        if let flags = UserDefaults.standard.stringArray(forKey: flagsKey) {
            availableFlags = flags
        }
    }
    
    func saveUsedFlag() {
        UserDefaults.standard.set(selectedFlag, forKey: usedFlagKey)
    }
    
    private func loadUsedFlag() {
        if let flags = UserDefaults.standard.string(forKey: usedFlagKey) {
            selectedFlag = flags
        }
    }
    
    func performGacha() -> String? {
        let gachaItems = ["🍎","🍋","🍓","🍉","🥦","🥑", "🧀", "🍔", "🎃", "🍀", "🌱", "💜", "🩵", "💛", "❤️","🤍", "🌊", "🌧️","❄️","🫧", "🌙","⭐️","🌍","🌈","🌕", "🌝", "😈", "👾", "👻", "💀", "💩", "🐶", "🐭", "🐰", "🐹", "🐼","🦁", "🙈", "🐽", "🦄", "🐥", "🐣","🐿️", "🪼", "🕷️", "🍄", "🎅","❣️","🧚","👑","🐸","🍕","🍟","🍣","🍭","🥨","🚀","🏖️","🏩",
//                          "똥",
                          "❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌"]
        let cost = 100
        if deductPoints(cost) {
            let newItem = gachaItems.randomElement() ?? "🚩"
            if newItem == "❌" {
                GameDataManager.shared.saveData(value: 1, key: Keys.failGachaCount)
            }
            addFlag(newItem)
            return newItem
        }
        return nil
    }
    

    func setDifficulty(_ difficulty: Difficulty) {
        currentDifficulty = difficulty
        let settings = difficulty.gridSettings
        gridHeightSize = settings.height
        mineCount = settings.mines
        resetGame()
    }

    func resetGame() {
        grid = Array(repeating: Array(repeating: Cell(), count: gridWidthSize), count: gridHeightSize)
        flagsPlaced = 0
        calculateAdjacentMines()
        
    }

    private func placeMines() {
        var minesPlaced = 0
        while minesPlaced < mineCount {
            let row = Int.random(in: 0..<gridHeightSize)
            let col = Int.random(in: 0..<gridWidthSize)

            if !grid[row][col].isMine {
                grid[row][col].isMine = true
                minesPlaced += 1
            }
        }
    }

    private func calculateAdjacentMines() {
        for row in 0..<gridHeightSize {
            for col in 0..<gridWidthSize {
                if !grid[row][col].isMine {
                    grid[row][col].adjacentMines = countMinesAround(row: row, col: col)
                }
            }
        }
    }

    private func countMinesAround(row: Int, col: Int) -> Int {
        let directions = [(-1, -1), (-1, 0), (-1, 1),
                          (0, -1),         (0, 1),
                          (1, -1), (1, 0), (1, 1)]
        return directions.reduce(0) { count, direction in
            let newRow = row + direction.0
            let newCol = col + direction.1
            if newRow >= 0, newRow < gridHeightSize, newCol >= 0, newCol < gridWidthSize, grid[newRow][newCol].isMine {
                return count + 1
            }
            return count
        }
    }

    
    func revealCell(row: Int, col: Int) {
        // 첫 클릭 시 지뢰 배치 및 확장 공개
        if grid.allSatisfy({ $0.allSatisfy { !$0.isRevealed } }) {
            placeMines(except: (row, col))
            calculateAdjacentMines()
            revealEmptyCells(row: row, col: col)  // 첫 클릭 시 확장 공개
            debugPrintGrid() // 디버깅용 답지 출력
        }

        if grid[row][col].isRevealed || grid[row][col].isFlagged {
            DispatchQueue.main.async {
                Sound.tap()
            }
            return
        }
        grid[row][col].isRevealed = true

        DispatchQueue.main.async {
            Haptic.impact(style: .soft)
            Sound.tap()
        }

        if grid[row][col].adjacentMines == 0 {
            revealEmptyCells(row: row, col: col)
        }
    }
    
    private func placeMines(except: (Int, Int)) {
        var minesPlaced = 0
        let safeRadius = 2 // 첫 클릭 주변 2칸은 안전
        while minesPlaced < mineCount {
            let row = Int.random(in: 0..<gridHeightSize)
            let col = Int.random(in: 0..<gridWidthSize)

            // 첫 클릭 위치와 주변 2칸을 피하기
            if abs(row - except.0) <= safeRadius && abs(col - except.1) <= safeRadius {
                continue
            }

            if !grid[row][col].isMine {
                grid[row][col].isMine = true
                minesPlaced += 1
            }
        }
    }
    
    private func revealEmptyCells(row: Int, col: Int) {
        var queue: [(Int, Int)] = [(row, col)]
        let directions = [(-1, -1), (-1, 0), (-1, 1),
                          (0, -1),         (0, 1),
                          (1, -1), (1, 0), (1, 1)]

        while !queue.isEmpty {
            let (currentRow, currentCol) = queue.removeFirst()
            
            // 🏳️ 깃발 제거 로직 추가
            if grid[currentRow][currentCol].isFlagged {
                grid[currentRow][currentCol].isFlagged = false
                flagsPlaced -= 1 // 깃발 수 감소
            }
            
            for direction in directions {
                let newRow = currentRow + direction.0
                let newCol = currentCol + direction.1

                if newRow >= 0, newRow < gridHeightSize, newCol >= 0, newCol < gridWidthSize {
                    
                    if !grid[newRow][newCol].isRevealed && !grid[newRow][newCol].isMine {
                        grid[newRow][newCol].isRevealed = true
                        
                        // 깃발 제거 로직
                        if grid[newRow][newCol].isFlagged {
                            grid[newRow][newCol].isFlagged = false
                            flagsPlaced -= 1
                        }
                        
                        if grid[newRow][newCol].adjacentMines == 0 {
                            queue.append((newRow, newCol))
                        }
                    }
                }
            }
        }
    }

    func toggleFlag(row: Int, col: Int) {
        if !grid[row][col].isRevealed {
            grid[row][col].isFlagged.toggle()
            flagsPlaced += grid[row][col].isFlagged ? 1 : -1
        }
    }

    func checkForWin() -> Bool {
        for row in 0..<gridHeightSize {
            for col in 0..<gridWidthSize {
                let cell = grid[row][col]
                if (cell.isMine && !cell.isFlagged) || (!cell.isMine && !cell.isRevealed) {
                    return false
                }
            }
        }
        return true
    }

    // 디버깅용: 답지 출력
    private func debugPrintGrid() {
        print("지뢰 찾기 답지:")
        for row in grid {
            var line = ""
            for cell in row {
                if cell.isMine {
                    line += "💣 "
                } else {
                    line += "\(cell.adjacentMines) "
                }
            }
            print(line)
        }
    }
}
