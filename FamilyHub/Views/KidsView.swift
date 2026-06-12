import SwiftUI
import SwiftData

struct KidsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Child.birthDate) private var kids: [Child]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                if kids.isEmpty {
                    ContentUnavailableView(
                        "No kids added",
                        systemImage: "figure.and.child.holdinghands",
                        description: Text("Tap + to add your first child.")
                    )
                }
                ForEach(kids) { child in
                    NavigationLink(value: child) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(child.name)
                                .font(.headline)
                            Text("\(child.ageDescription) · Today: \(child.todayPlanDescription)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(kids[index])
                    }
                }
            }
            .navigationTitle("Kids")
            .navigationDestination(for: Child.self) { child in
                ChildDetailView(child: child)
            }
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddChildSheet()
            }
        }
    }
}

// MARK: - Child detail (edit name, birth date, and the weekly schedule)

struct ChildDetailView: View {
    @Bindable var child: Child

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $child.name)
                DatePicker("Birth date", selection: $child.birthDate, in: ...Date.now, displayedComponents: .date)
            }

            Section {
                ForEach(child.sortedSchedule) { plan in
                    DayPlanEditor(plan: plan)
                }
            } header: {
                Text("Weekly schedule")
            } footer: {
                Text("Changes save automatically.")
            }
        }
        .navigationTitle(child.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            child.ensureFullWeek()
        }
    }
}

// Editing rows bind straight to the DayPlan model, so SwiftData
// persists every change as it happens.
struct DayPlanEditor: View {
    @Bindable var plan: DayPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Picker(plan.weekday.name, selection: $plan.careType) {
                ForEach(CareType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            TextField("Activity (e.g. swimming, dance class)", text: $plan.activity)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Add child

struct AddChildSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -4, to: .now) ?? .now

    // Drafts for each weekday; turned into DayPlan models on save.
    private struct DayDraft {
        var careType: CareType = .atHome
        var activity = ""
    }

    @State private var days: [DayDraft] = Weekday.allCases.map { _ in DayDraft() }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    DatePicker("Birth date", selection: $birthDate, in: ...Date.now, displayedComponents: .date)
                }

                Section {
                    ForEach(Weekday.allCases) { weekday in
                        VStack(alignment: .leading, spacing: 4) {
                            Picker(weekday.name, selection: $days[weekday.rawValue - 1].careType) {
                                ForEach(CareType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            TextField("Activity (e.g. swimming, dance class)",
                                      text: $days[weekday.rawValue - 1].activity)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text("Weekly schedule")
                } footer: {
                    Text("Where does \(name.isEmpty ? "your child" : name) go each day? You can change this anytime.")
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let mainCare = days.map(\.careType).first { $0 != .atHome } ?? .atHome
        let child = Child(
            name: name.trimmingCharacters(in: .whitespaces),
            birthDate: birthDate,
            careType: mainCare
        )
        modelContext.insert(child)
        for weekday in Weekday.allCases {
            let draft = days[weekday.rawValue - 1]
            child.schedule.append(
                DayPlan(
                    weekday: weekday,
                    careType: draft.careType,
                    activity: draft.activity.trimmingCharacters(in: .whitespaces)
                )
            )
        }
        dismiss()
    }
}

#Preview {
    KidsView()
        .modelContainer(for: [Child.self, DayPlan.self, Checklist.self], inMemory: true)
}
