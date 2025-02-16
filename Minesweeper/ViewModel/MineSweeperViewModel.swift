//
//  MineSweeperViewModel.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI

// MARK: - ViewModel
class MineSweeperViewModel: ObservableObject {
    @Published var grid: [[Cell]] = []
    @Published var gridWidthSize: Int = 8
    @Published var gridHeightSize: Int = 10
    @Published var mineCount: Int = 15
    @Published var flagsPlaced: Int = 0
    @Published var points: Int = 0
    @Published var selectedFlag: String = "🚩" // 기본 플래그
    @Published var availableFlags: [String] = ["🚩"]
    
    private let pointsKey = "userPoints"
    private let flagsKey = "userFlags"
    
    init() {
        loadPoints()
        loadFlags()
        resetGame()
    }

    func addPoints(_ amount: Int) {
        points += amount
        savePoints()
    }
    
    func deductPoints(_ amount: Int) -> Bool {
        if points >= amount {
            points -= amount
            savePoints()
            return true
        }
        return false
    }
    private func savePoints() {
        UserDefaults.standard.set(points, forKey: pointsKey)
    }
    
    private func loadPoints() {
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
    
    func performGacha() -> String? {
        let gachaItems = ["🍎","🍋","🍓","🍉","🥦","🥑", "🧀", "🍔", "🎃", "🍀", "🌱", "💜", "🩵", "💛", "❤️","🤍", "🌊", "🌧️","❄️","🫧", "🌙","⭐️","🌍","🌈","🌕", "🌝", "😈", "👾", "👻", "💀", "💩", "🐶", "🐭", "🐰", "🐹", "🐼","🦁", "🙈", "🐽", "🦄", "🐥", "🐣","🐿️", "🪼", "🕷️", "🍄", "🎅","❣️", "❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌","❌"]
        let cost = 100
        if deductPoints(cost) {
            let newItem = gachaItems.randomElement() ?? "🚩"
            addFlag(newItem)
            return newItem
        }
        return nil
    }
    

    func setDifficulty(level: String) {
        switch level {
        case "easy":
            gridHeightSize = 8
            mineCount = 8
        case "normal":
            gridHeightSize = 10
            mineCount = 15
        default:
            if DeviceUtils.hasNotch {
                print("✅ 이 기기는 노치가 있습니다!")
                gridHeightSize = 14
                mineCount = 27
            } else {
                gridHeightSize = 12
                mineCount = 22
                print("❌ 이 기기는 노치가 없습니다!")
            }
            
        }
        resetGame()
    }

    func resetGame() {
        grid = Array(repeating: Array(repeating: Cell(), count: gridWidthSize), count: gridHeightSize)
        flagsPlaced = 0
        placeMines()
        calculateAdjacentMines()
        debugPrintGrid() // 디버깅용 답지 출력
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
        if grid[row][col].isRevealed || grid[row][col].isFlagged {
            return
        }
        grid[row][col].isRevealed = true
        DispatchQueue.main.async {
            Haptic.impact(style: .soft)
        }
        if grid[row][col].adjacentMines == 0 {
            revealEmptyCells(row: row, col: col)
        }
    }

    private func revealEmptyCells(row: Int, col: Int) {
        let directions = [(-1, -1), (-1, 0), (-1, 1),
                          (0, -1),         (0, 1),
                          (1, -1), (1, 0), (1, 1)]

        for direction in directions {
            let newRow = row + direction.0
            let newCol = col + direction.1

            if newRow >= 0, newRow < gridHeightSize, newCol >= 0, newCol < gridWidthSize {
                let cell = grid[newRow][newCol]

                if cell.isRevealed || cell.isMine {
                    continue
                }

                grid[newRow][newCol].isRevealed = true

                if cell.adjacentMines == 0 {
                    revealEmptyCells(row: newRow, col: newCol)
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
