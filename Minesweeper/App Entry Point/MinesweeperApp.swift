import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds


// MARK: - App Entry Point
@main
struct MineSweeperApp: App {
    @State private var isShowingSplash = true
    init() {
        requestTrackingAuthorization()
        requestTrackingPermission()
        
    }
    var body: some Scene {
        WindowGroup {
            MainView()    // ✅ 메인 화면
        }
    }
}

func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("Tracking authorized")
            case .denied:
                print("Tracking denied")
            case .notDetermined:
                print("Tracking not determined")
            case .restricted:
                print("Tracking restricted")
            @unknown default:
                print("Unknown status")
            }
        }
    }

func requestTrackingPermission() {
    ATTrackingManager.requestTrackingAuthorization { status in
        DispatchQueue.main.async {
            GADMobileAds.sharedInstance().start { status in
                let adapterStatuses = status.adapterStatusesByClassName
                for (adapter, status) in adapterStatuses {
                    print("Adapter Name: \(adapter), Description: \(status.description), State: \(status.state.rawValue)")
                }
            }
//            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [GADSimulatorID]
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
                        colors: [
                            Color(red: 0.98, green: 0.99, blue: 1.00), // soft ice blue
                            Color(red: 0.97, green: 1.00, blue: 0.98)  // whisper mint
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image("Minesweeper_logo")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding(.bottom)
                            .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                        
                        Text("\(NSLocalizedString("minesweeper", comment: ""))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                            .padding()
                        
                        Button {
                            showGameView = true
                        } label: {
                            Text("\(NSLocalizedString("start_game", comment: ""))")
                                .font(.headline)
                                .padding(.horizontal, 14)       // 내부 세로 패딩
                                .foregroundColor(.white)   
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
        .onAppear {
            AppBootstrap.configureAudioSession()
        }
    }
}
