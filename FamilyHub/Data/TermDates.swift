import Foundation

// MARK: - States

enum AUState: String, CaseIterable, Identifiable {
    case nsw = "NSW"
    case vic = "VIC"
    case qld = "QLD"
    case wa = "WA"
    case sa = "SA"
    case tas = "TAS"
    case act = "ACT"
    case nt = "NT"

    var id: String { rawValue }
}

// MARK: - Terms

struct Term: Identifiable {
    let number: Int
    let start: Date
    let end: Date

    var id: Int { number }
}

struct TermEvent {
    let label: String
    let date: Date

    var daysAway: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: .now),
            to: Calendar.current.startOfDay(for: date)
        ).day ?? 0
    }
}

// MARK: - 2026 data

// SEED DATA — government school dates compiled June 2026. States publish
// changes, and private/independent schools differ, so the app shows a
// "verify with your school" note. In a future version this should be
// fetched from a server so dates update without an App Store release.
enum TermDates2026 {
    static func terms(for state: AUState) -> [Term] {
        switch state {
        case .nsw:
            return [
                Term(number: 1, start: d(2, 2), end: d(4, 2)),
                Term(number: 2, start: d(4, 22), end: d(7, 3)),
                Term(number: 3, start: d(7, 21), end: d(9, 25)),
                Term(number: 4, start: d(10, 13), end: d(12, 17)),
            ]
        case .vic:
            return [
                Term(number: 1, start: d(1, 28), end: d(4, 2)),
                Term(number: 2, start: d(4, 20), end: d(6, 26)),
                Term(number: 3, start: d(7, 13), end: d(9, 18)),
                Term(number: 4, start: d(10, 5), end: d(12, 18)),
            ]
        case .qld:
            return [
                Term(number: 1, start: d(1, 27), end: d(4, 2)),
                Term(number: 2, start: d(4, 20), end: d(6, 26)),
                Term(number: 3, start: d(7, 13), end: d(9, 18)),
                Term(number: 4, start: d(10, 6), end: d(12, 11)),
            ]
        case .wa:
            return [
                Term(number: 1, start: d(2, 2), end: d(4, 2)),
                Term(number: 2, start: d(4, 20), end: d(7, 3)),
                Term(number: 3, start: d(7, 20), end: d(9, 25)),
                Term(number: 4, start: d(10, 12), end: d(12, 17)),
            ]
        case .sa:
            return [
                Term(number: 1, start: d(1, 27), end: d(4, 10)),
                Term(number: 2, start: d(4, 27), end: d(7, 3)),
                Term(number: 3, start: d(7, 20), end: d(9, 25)),
                Term(number: 4, start: d(10, 12), end: d(12, 11)),
            ]
        case .tas:
            return [
                Term(number: 1, start: d(2, 5), end: d(4, 10)),
                Term(number: 2, start: d(4, 27), end: d(7, 3)),
                Term(number: 3, start: d(7, 20), end: d(9, 25)),
                Term(number: 4, start: d(10, 12), end: d(12, 17)),
            ]
        case .act:
            return [
                Term(number: 1, start: d(2, 2), end: d(4, 2)),
                Term(number: 2, start: d(4, 20), end: d(7, 3)),
                Term(number: 3, start: d(7, 20), end: d(9, 25)),
                Term(number: 4, start: d(10, 12), end: d(12, 17)),
            ]
        case .nt:
            return [
                Term(number: 1, start: d(1, 28), end: d(4, 2)),
                Term(number: 2, start: d(4, 13), end: d(6, 19)),
                Term(number: 3, start: d(7, 14), end: d(9, 18)),
                Term(number: 4, start: d(10, 5), end: d(12, 11)),
            ]
        }
    }

    /// The next term start or end after `date`, e.g. "Term 2 ends".
    static func nextEvent(for state: AUState, after date: Date = .now) -> TermEvent? {
        var events: [TermEvent] = []
        for term in terms(for: state) {
            events.append(TermEvent(label: "Term \(term.number) starts", date: term.start))
            events.append(TermEvent(label: "Term \(term.number) ends", date: term.end))
        }
        return events
            .filter { $0.date >= Calendar.current.startOfDay(for: date) }
            .min { $0.date < $1.date }
    }

    private static func d(_ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: month, day: day)) ?? .now
    }
}
