import SwiftUI
import SwiftData

struct ChecklistsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Checklist.createdAt) private var checklists: [Checklist]
    @State private var showingNewChecklistAlert = false
    @State private var newChecklistTitle = ""

    var body: some View {
        NavigationStack {
            List {
                if checklists.isEmpty {
                    ContentUnavailableView(
                        "No checklists yet",
                        systemImage: "checklist",
                        description: Text("Tap + to start from a template like Daycare Bag or Kindy Enrolment.")
                    )
                }
                ForEach(checklists) { checklist in
                    NavigationLink(value: checklist) {
                        HStack {
                            Text(checklist.title)
                            Spacer()
                            Text("\(checklist.doneCount)/\(checklist.items.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(checklists[index])
                    }
                }
            }
            .navigationTitle("Checklists")
            .navigationDestination(for: Checklist.self) { checklist in
                ChecklistDetailView(checklist: checklist)
            }
            .toolbar {
                Menu {
                    ForEach(ChecklistTemplate.allCases) { template in
                        Button(template.rawValue) {
                            modelContext.insert(template.makeChecklist())
                        }
                    }
                    Button("Blank checklist…") {
                        newChecklistTitle = ""
                        showingNewChecklistAlert = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            .alert("New checklist", isPresented: $showingNewChecklistAlert) {
                TextField("Title", text: $newChecklistTitle)
                Button("Create") {
                    let title = newChecklistTitle.trimmingCharacters(in: .whitespaces)
                    if !title.isEmpty {
                        modelContext.insert(Checklist(title: title))
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct ChecklistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var checklist: Checklist
    @State private var newItemTitle = ""

    private var sortedItems: [ChecklistItem] {
        checklist.items.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        List {
            ForEach(sortedItems) { item in
                Button {
                    item.isDone.toggle()
                } label: {
                    HStack {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isDone ? .green : .secondary)
                        Text(item.title)
                            .strikethrough(item.isDone)
                            .foregroundStyle(item.isDone ? .secondary : .primary)
                    }
                }
                .buttonStyle(.plain)
            }
            .onDelete { offsets in
                let items = sortedItems
                for index in offsets {
                    modelContext.delete(items[index])
                }
            }

            Section {
                HStack {
                    TextField("Add item…", text: $newItemTitle)
                        .onSubmit(addItem)
                    Button("Add", action: addItem)
                        .disabled(newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .navigationTitle(checklist.title)
        .toolbar {
            Button("Reset") {
                for item in checklist.items {
                    item.isDone = false
                }
            }
        }
    }

    private func addItem() {
        let title = newItemTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        let nextOrder = (checklist.items.map(\.sortOrder).max() ?? -1) + 1
        let item = ChecklistItem(title: title, sortOrder: nextOrder)
        checklist.items.append(item)
        newItemTitle = ""
    }
}

#Preview {
    ChecklistsView()
        .modelContainer(for: [Child.self, Checklist.self], inMemory: true)
}
