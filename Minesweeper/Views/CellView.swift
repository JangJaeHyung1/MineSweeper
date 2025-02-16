//
//  CellView.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI

// MARK: - Cell View
struct CellView: View {
    let cell: Cell
    let cellSize: CGFloat
    let flag: String
    @Environment(\.colorScheme) var colorScheme
    func bgColorForMode() -> Color {
        return colorScheme == .dark ? .black : .white
    }
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(cell.isRevealed ? (cell.isMine ? UserSettings.mineColor : bgColorForMode()) : UserSettings.unrevealedColor)
                .frame(width: cellSize, height: cellSize)
                .cornerRadius(5)
                .scaleEffect(cell.isRevealed ? 1.1 : 1.0) // 클릭 애니메이션
                .animation(.easeInOut, value: cell.isRevealed)

            if cell.isFlagged {
                Text(flag)
                    .font(.system(size: cellSize * 0.7))
                    .foregroundColor(.white)
            } else if cell.isRevealed {
                if cell.isMine {
                    Text("💣")
                        .font(.system(size: cellSize * 0.5))
                        .foregroundColor(.white)
                } else if cell.adjacentMines > 0 {
                    Text("\(cell.adjacentMines)")
                        .font(.system(size: cellSize * 0.6, weight: .bold, design: .rounded))
                        .foregroundColor(colorForMineCount(cell.adjacentMines))
                }
            }
        }
    }
    private func colorForMineCount(_ count: Int) -> Color {
        switch count {
        case 1: return .green
        case 2: return .blue
        case 3: return .orange
        case 4...: return .red
        default: return .white
        }
    }
}
