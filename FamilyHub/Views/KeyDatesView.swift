import SwiftUI
import SwiftData

struct KeyDatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyEvent.date) private var events: [FamilyEvent]
    @State private var showingAddSheet = false

    private var upcoming: [FamilyEvent] { events.filter(\.isUpcoming) }
    private var past: [FamilyEvent] { events.filter { !$0.isUpcoming }.reversed() }

    var body: some View {
        List {
            if events.isEmpty {
                ContentUnavailableView(
                    "No key dates yet",
                    systemImage: "star.circle",
                    description: Text("Tap + to add things like the school fete, photo day, an excursion, or a pupil-free day.")
                )
            }

            if !upcoming.isEmpty {
                Section("Upcoming") {
                    ForEach(upcoming) { event in
                        NavigationLink(value: event) {
                            EventRow(event: event)
                        }
                    }
                    .onDelete { offsets in
                        delete(at: offsets, from: upcoming)
                    }
                }
            }

            if !past.isEmpty {
                Section("Past") {
                    ForEach(past) { event in
                        EventRow(event: event)
                            .foregroundStyle(.secondary)
                    }
                    .onDelete { offsets in
                        delete(at: offsets, from: past)
                    }
                }
            }
        }
        .navigationTitle("Key Dates")
        .navigationDestination(for: FamilyEvent.self) { event in
            EventEditorView(event: event)
        }
        .toolbar {
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEventSheet()
        }
    }

    private func delete(at offsets: IndexSet, from list: [FamilyEvent]) {
        for index in offsets {
            ReminderScheduler.cancel(for: list[index])
            modelContext.delete(list[index])
        }
    }
}

struct EventRow: View {
    let event: FamilyEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                if event.reminderEnabled {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundStyle(.tint)
                }
            }
            HStack {
                Text(event.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                if let child = event.child {
                    Text("· \(child.name)")
                }
                Spacer()
                if event.isUpcoming {
                    Text(event.daysAway == 0 ? "Today" : "in \(event.daysAway) days")
                        .foregroundStyle(.tint)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if !event.notes.isEmpty {
                Text(event.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Edit an existing event

struct EventEditorView: View {
    @Bindable var event: FamilyEvent
    @Query(sort: \Child.birthDate) private var kids: [Child]

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $event.title)
                DatePicker("Date", selection: $event.date, displayedComponents: .date)
                Picker("Who", selection: $event.child) {
                    Text("Whole family").tag(nil as Child?)
                    ForEach(kids) { child in
                        Text(child.name).tag(child as Child?)
                    }
                }
                TextField("Notes (e.g. costume needed, $15 + permission slip)",
                          text: $event.notes, axis: .vertical)
            }

            Section {
                Toggle("Remind me", isOn: $event.reminderEnabled)
            } footer: {
                Text("You'll get a notification at 6 pm the evening before (or 7 am on the day if it's already close).")
            }
        }
        .navigationTitle(event.title.isEmpty ? "Key Date" : event.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: event.reminderEnabled) { _, isOn in
            if isOn {
                Task {
                    if await ReminderScheduler.requestPermission() {
                        ReminderScheduler.schedule(for: event)
                    } else {
                        event.reminderEnabled = false
                    }
                }
            } else {
                ReminderScheduler.cancel(for: event)
            }
        }
        .onDisappear {
            // Re-schedule on the way out so edits to the title, date or
            // notes are reflected in the pending notification.
            if event.reminderEnabled {
                ReminderScheduler.schedule(for: event)
            }
        }
    }
}

// MARK: - Add a new event

struct AddEventSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Child.birthDate) private var kids: [Child]

    @State private var title = ""
    @State private var date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var notes = ""
    @State private var child: Child?
    @State private var reminderEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title (e.g. School fete, Photo day)", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Who", selection: $child) {
                        Text("Whole family").tag(nil as Child?)
                        ForEach(kids) { kid in
                            Text(kid.name).tag(kid as Child?)
                        }
                    }
                    TextField("Notes (e.g. costume needed, $15 + permission slip)",
                              text: $notes, axis: .vertical)
                }

                Section {
                    Toggle("Remind me", isOn: $reminderEnabled)
                } footer: {
                    Text("You'll get a notification at 6 pm the evening before.")
                }
            }
            .navigationTitle("New Key Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let event = FamilyEvent(
            title: title.trimmingCharacters(in: .whitespaces),
            date: date,
            notes: notes.trimmingCharacters(in: .whitespaces),
            reminderEnabled: reminderEnabled,
            child: child
        )
        modelContext.insert(event)
        if reminderEnabled {
            Task {
                if await ReminderScheduler.requestPermission() {
                    ReminderScheduler.schedule(for: event)
                } else {
                    event.reminderEnabled = false
                }
            }
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        KeyDatesView()
    }
    .modelContainer(for: [Child.self, DayPlan.self, FamilyEvent.self, Checklist.self], inMemory: true)
}
