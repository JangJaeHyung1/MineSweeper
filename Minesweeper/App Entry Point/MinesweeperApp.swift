import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds


// MARK: - App Entry Point
@main
struct MineSweeperApp: App {
    @State private var isShowingSplash = true
    init() {
        requestTrackingPermission()
    }
    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashView()  // ✅ 스플래시 화면
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 3초 후 메인 화면 전환
                            isShowingSplash = false
                        }
                    }
            } else {
                MainView()    // ✅ 메인 화면
            }
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
                        Image("Minesweeper_logo")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .padding(.bottom)
                        
                        Text("\(NSLocalizedString("minesweeper", comment: ""))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button("\(NSLocalizedString("start_game", comment: ""))") {
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

