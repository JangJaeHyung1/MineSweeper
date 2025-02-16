import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds


// MARK: - App Entry Point
@main
struct MineSweeperApp: App {
    init() {
        requestTrackingPermission()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

func requestTrackingPermission() {
    ATTrackingManager.requestTrackingAuthorization { status in
        DispatchQueue.main.async {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
    }
}

// MARK: - Main View (메인 화면)
struct MainView: View {
    @State private var showGameView = false

    var body: some View {
        NavigationView {
                ZStack {
                    
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("minesweeper")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button("start_game") {
                            showGameView = true
                        }
                        .padding()
                        .background(.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        NavigationLink(
                            destination: MineSweeperView(),
                            isActive: $showGameView,
                            label: { EmptyView() }
                        )
                    }
                    
            }
        }
    }
}

