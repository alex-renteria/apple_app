import SwiftUI
import SwiftData

// The entry point of the app. `@main` tells iOS to start here.
// `.modelContainer` sets up the on-device database (SwiftData) that
// stores your kids and checklists between launches.
@main
struct FamilyHubApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Child.self, Checklist.self])
    }
}
