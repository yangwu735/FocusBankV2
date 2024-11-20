import SwiftUI
import SwiftData
import FirebaseCore
import FamilyControls
import DeviceActivity


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct FocusBankApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DefaultView()
                .onAppear {
                    Task {
                        await requestScreenTimeAuthorization(for: FamilyControls.AuthorizationScope.individual)
                        checkScreenTimeAuthorizationStatus()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // Request Screen Time authorization for the current user
    func requestScreenTimeAuthorization(for user: AuthorizationScope) async {
        let authorizationCenter = AuthorizationCenter.shared
        do {
            try await authorizationCenter.requestAuthorization(for: user)
            print("Screen Time authorization granted for \(user).")
        } catch {
            print("Failed to obtain Screen Time authorization: \(error)")
        }
    }
    
    // Check Screen Time authorization status
    func checkScreenTimeAuthorizationStatus() {
        let authorizationCenter = AuthorizationCenter.shared
        if authorizationCenter.authorizationStatus == .approved {
            print("Screen Time access is approved.")
        } else {
            print("Screen Time access not approved.")
        }
    }
}
