import SwiftUI

// 2026 government school term dates by state. Kindy/preschool programs
// generally follow these too.
struct TermDatesView: View {
    @AppStorage("homeState") private var homeStateRaw = AUState.nsw.rawValue

    private var homeState: AUState {
        AUState(rawValue: homeStateRaw) ?? .nsw
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("State", selection: $homeStateRaw) {
                        ForEach(AUState.allCases) { state in
                            Text(state.rawValue).tag(state.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    Text("2026 government school dates. Private and independent schools differ — always check your school's calendar.")
                }

                ForEach(TermDates2026.terms(for: homeState)) { term in
                    Section("Term \(term.number)") {
                        LabeledContent("Starts") {
                            Text(term.start, format: .dateTime.weekday(.abbreviated).day().month(.wide))
                        }
                        LabeledContent("Ends") {
                            Text(term.end, format: .dateTime.weekday(.abbreviated).day().month(.wide))
                        }
                        if let weeks = Calendar.current.dateComponents(
                            [.weekOfYear], from: term.start, to: term.end
                        ).weekOfYear {
                            LabeledContent("Length") {
                                Text("\(weeks + 1) weeks")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Term Dates 2026")
        }
    }
}

#Preview {
    TermDatesView()
}
