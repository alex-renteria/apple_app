import SwiftUI

// The root view: a tab bar with the app's five main screens.
struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max.fill") }

            CCSEstimatorView()
                .tabItem { Label("CCS", systemImage: "dollarsign.circle.fill") }

            TermDatesView()
                .tabItem { Label("Terms", systemImage: "calendar") }

            ChecklistsView()
                .tabItem { Label("Checklists", systemImage: "checklist") }

            KidsView()
                .tabItem { Label("Kids", systemImage: "figure.and.child.holdinghands") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Child.self, DayPlan.self, FamilyEvent.self, Checklist.self], inMemory: true)
}
