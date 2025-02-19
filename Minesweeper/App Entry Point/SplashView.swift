//
//  SplashView.swift
//  Minesweeper
//
//  Created by jh on 2/20/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Image("Minesweeper_logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.bottom)
                Text("\(NSLocalizedString("minesweeper", comment: ""))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}
