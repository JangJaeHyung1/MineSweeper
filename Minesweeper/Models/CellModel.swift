//
//  CellModel.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI

// MARK: - Cell 데이터 모델
struct Cell: Identifiable {
    let id = UUID()
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var adjacentMines: Int = 0
}

// MARK: - User Settings (타일 색상 커스터마이징)
struct UserSettings {
    static var unrevealedColor: Color = Color(UIColor.systemGray5)
    static var revealedColor: Color = .white
    static var mineColor: Color = .red
}
