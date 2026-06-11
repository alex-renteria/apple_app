import SwiftUI
import SwiftData

// The dashboard: a quick glance at your kids, the next school-term
// milestone for your state, and how your checklists are going.
struct TodayView: View {
    // @AppStorage persists small preferences (like your home state)
    // without needing the database.
    @AppStorage("homeState") private var homeStateRaw = AUState.nsw.rawValue
    @Query(sort: \Child.birthDate) private var kids: [Child]
    @Query(sort: \Checklist.createdAt) private var checklists: [Checklist]

    private var homeState: AUState {
        AUState(rawValue: homeStateRaw) ?? .nsw
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Your state", selection: $homeStateRaw) {
                        ForEach(AUState.allCases) { state in
                            Text(state.rawValue).tag(state.rawValue)
                        }
                    }
                }

                Section("Coming up") {
                    if let event = TermDates2026.nextEvent(for: homeState) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.label)
                                    .font(.headline)
                                Text(event.date, format: .dateTime.weekday(.wide).day().month(.wide))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(event.daysAway == 0 ? "Today" : "\(event.daysAway) days")
                                .font(.title3.bold())
                                .foregroundStyle(.tint)
                        }
                    } else {
                        Text("No more term dates this year 🎉")
                    }
                }

                Section("Your kids") {
                    if kids.isEmpty {
                        Text("Add your kids in the Kids tab to see them here.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(kids) { child in
                            HStack {
                                Text(child.name)
                                Spacer()
                                Text("\(child.ageDescription) · \(child.careType.rawValue)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if !checklists.isEmpty {
                    Section("Checklists") {
                        ForEach(checklists) { checklist in
                            HStack {
                                Text(checklist.title)
                                Spacer()
                                Text("\(checklist.doneCount)/\(checklist.items.count)")
                                    .foregroundStyle(
                                        checklist.doneCount == checklist.items.count
                                            ? .green : .secondary
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [Child.self, Checklist.self], inMemory: true)
}
