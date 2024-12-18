import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FamilyControls
import DeviceActivity

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let _db = Firestore.firestore()
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
                    ZStack {
                        Color.black.ignoresSafeArea()
                        DefaultView()
                    }
                }
//        .modelContainer(sharedModelContainer)
    }
    
}
