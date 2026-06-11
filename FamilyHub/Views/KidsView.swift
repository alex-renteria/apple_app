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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(child.name)
                            .font(.headline)
                        Text("\(child.ageDescription) · \(child.careType.rawValue)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(kids[index])
                    }
                }
            }
            .navigationTitle("Kids")
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

struct AddChildSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -4, to: .now) ?? .now
    @State private var careType = CareType.longDayCare

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                DatePicker("Birth date", selection: $birthDate, in: ...Date.now, displayedComponents: .date)
                Picker("Care type", selection: $careType) {
                    ForEach(CareType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        modelContext.insert(
                            Child(
                                name: name.trimmingCharacters(in: .whitespaces),
                                birthDate: birthDate,
                                careType: careType
                            )
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    KidsView()
        .modelContainer(for: [Child.self, Checklist.self], inMemory: true)
}
