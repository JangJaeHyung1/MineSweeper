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

