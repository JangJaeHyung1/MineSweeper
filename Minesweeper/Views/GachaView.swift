//
//  GachaView.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI

struct GachaView: View {
    @ObservedObject var viewModel: MineSweeperViewModel
    @Binding var newItem: String?

    var gachaItems = ["🚩","🍎","🍋","🍓","🍉","🥦","🥑", "🧀", "🍔", "🎃", "🍀", "🌱", "💜", "🩵", "💛", "❤️","🤍", "🌊", "🌧️","❄️","🫧", "🌙","⭐️","🌍","🌈","🌕", "🌝", "😈", "👾", "👻", "💀", "💩", "🐶", "🐭", "🐰", "🐹", "🐼","🦁", "🙈", "🐽", "🦄", "🐥", "🐣","🐿️", "🪼", "🕷️", "🍄", "🎅","❣️","🧚","👑","🐸","🍕","🍟","🍣","🍭","🥨","🚀","🏖️","🏩",
//                      "똥",
    ]

    var body: some View {
        VStack(spacing: 20) {
            (
                Text("\(NSLocalizedString("getItem", comment: ""))")
                    .font(.title2)
                + Text("  \(newItem ?? "❓")")
                    .font(.largeTitle)
            )
                .padding()
            .padding()
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(gachaItems, id: \.self) { item in
                        Text(item)
                            .font(.title2)
                            .padding()
                            .background(viewModel.selectedFlag == item ? Color(UIColor.systemGray5) : Color.clear)
                            .clipShape(Circle())
                            .opacity(viewModel.availableFlags.contains(item) ? 1.0 : 0.3)
                            .onTapGesture {
                                if viewModel.availableFlags.contains(item) {
                                    viewModel.selectedFlag = item
                                    viewModel.saveUsedFlag()
                                }
                            }
                    }
                }
            }

            Spacer()

            Button(action: {
                if viewModel.points >= 100 {
                    let result = viewModel.performGacha()
                    if let item = result {
                        newItem = item
                    } else {
                        newItem = "❌"
                    }
                }
                Sound.pop()
            }) {
                Text("\(NSLocalizedString("gatchaStart", comment: ""))")
                    .font(.headline)
                    .padding()
                    .background(viewModel.points < 100 ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.points < 100)
            .padding(.bottom)
        }
        .padding()
    }
}
