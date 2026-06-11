import Foundation
import SwiftData

// MARK: - Child

// `@Model` makes this a SwiftData model: instances are automatically
// saved to the on-device database.
@Model
final class Child {
    var name: String
    var birthDate: Date
    // SwiftData stores simple types most reliably, so we keep the enum
    // as its raw String and expose a typed property below.
    var careTypeRaw: String

    init(name: String, birthDate: Date, careType: CareType) {
        self.name = name
        self.birthDate = birthDate
        self.careTypeRaw = careType.rawValue
    }

    var careType: CareType {
        get { CareType(rawValue: careTypeRaw) ?? .longDayCare }
        set { careTypeRaw = newValue.rawValue }
    }

    /// e.g. "4 yrs 2 mo"
    var ageDescription: String {
        let parts = Calendar.current.dateComponents([.year, .month], from: birthDate, to: .now)
        let years = parts.year ?? 0
        let months = parts.month ?? 0
        if years == 0 { return "\(months) mo" }
        if months == 0 { return "\(years) yrs" }
        return "\(years) yrs \(months) mo"
    }
}

enum CareType: String, CaseIterable, Identifiable {
    case longDayCare = "Long Day Care"
    case familyDayCare = "Family Day Care"
    case kindy = "Kindy / Preschool"
    case school = "School"
    case atHome = "At Home"

    var id: String { rawValue }
}

// MARK: - Checklists

@Model
final class Checklist {
    var title: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.checklist)
    var items: [ChecklistItem]

    init(title: String, items: [ChecklistItem] = []) {
        self.title = title
        self.createdAt = .now
        self.items = items
    }

    var doneCount: Int { items.filter(\.isDone).count }
}

@Model
final class ChecklistItem {
    var title: String
    var isDone: Bool
    var sortOrder: Int
    var checklist: Checklist?

    init(title: String, isDone: Bool = false, sortOrder: Int = 0) {
        self.title = title
        self.isDone = isDone
        self.sortOrder = sortOrder
    }
}

// MARK: - Checklist templates

// Ready-made checklists for the 3–5 age group. Adding more templates
// later is just adding entries to this array.
enum ChecklistTemplate: String, CaseIterable, Identifiable {
    case daycareBag = "Daycare Bag"
    case kindyEnrolment = "Kindy / Preschool Enrolment"
    case startingSchool = "Starting School Prep"

    var id: String { rawValue }

    var items: [String] {
        switch self {
        case .daycareBag:
            return [
                "Spare clothes (x2)",
                "Sun hat",
                "Water bottle",
                "Lunch & snacks",
                "Nappies / pull-ups if needed",
                "Comfort toy",
                "Sunscreen applied before drop-off",
                "Sign in on the centre app",
            ]
        case .kindyEnrolment:
            return [
                "Birth certificate copy",
                "Immunisation History Statement (from Medicare/myGov)",
                "Proof of address",
                "Medicare card details",
                "Emergency contact details",
                "Confirm CCS enrolment in myGov (CWA agreement)",
                "Medical / allergy action plans if needed",
                "Book orientation visit",
            ]
        case .startingSchool:
            return [
                "Check school catchment & enrolment dates",
                "Attend school open day",
                "Uniform & shoes",
                "School bag, lunchbox, drink bottle",
                "Label everything with name",
                "Book Before/After School Care if needed",
                "Practise lunchbox opening & toilet independence",
            ]
        }
    }

    func makeChecklist() -> Checklist {
        let checklist = Checklist(title: rawValue)
        checklist.items = items.enumerated().map { index, title in
            ChecklistItem(title: title, sortOrder: index)
        }
        return checklist
    }
}
