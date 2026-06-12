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
    // Superseded by the per-day `schedule`, but kept so existing saved
    // data still loads; treat it as the fallback when a day has no plan.
    var careTypeRaw: String
    @Relationship(deleteRule: .cascade, inverse: \DayPlan.child)
    var schedule: [DayPlan]
    // If a child is removed, their events stay but become "whole family".
    @Relationship(deleteRule: .nullify, inverse: \FamilyEvent.child)
    var events: [FamilyEvent]

    init(name: String, birthDate: Date, careType: CareType) {
        self.name = name
        self.birthDate = birthDate
        self.careTypeRaw = careType.rawValue
        self.schedule = []
        self.events = []
    }

    var careType: CareType {
        get { CareType(rawValue: careTypeRaw) ?? .longDayCare }
        set { careTypeRaw = newValue.rawValue }
    }

    var sortedSchedule: [DayPlan] {
        schedule.sorted { $0.weekdayRaw < $1.weekdayRaw }
    }

    func plan(for weekday: Weekday) -> DayPlan? {
        schedule.first { $0.weekdayRaw == weekday.rawValue }
    }

    /// Kids created before the schedule feature (or with missing days)
    /// get a full week of default "At Home" plans.
    func ensureFullWeek() {
        for weekday in Weekday.allCases where plan(for: weekday) == nil {
            schedule.append(DayPlan(weekday: weekday))
        }
    }

    /// e.g. "Kindy / Preschool · Dance class"
    var todayPlanDescription: String {
        guard let plan = plan(for: .today) else { return careType.rawValue }
        if plan.activity.isEmpty { return plan.careType.rawValue }
        return "\(plan.careType.rawValue) · \(plan.activity)"
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
    case grandparents = "Grandparents"
    case atHome = "At Home"

    var id: String { rawValue }
}

// MARK: - Weekly schedule

enum Weekday: Int, CaseIterable, Identifiable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: Int { rawValue }

    var name: String {
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][rawValue - 1]
    }

    static var today: Weekday {
        // Calendar uses 1 = Sunday … 7 = Saturday; we use 1 = Monday.
        let calendarWeekday = Calendar.current.component(.weekday, from: .now)
        return Weekday(rawValue: calendarWeekday == 1 ? 7 : calendarWeekday - 1) ?? .monday
    }
}

/// Where a child is (and what they do) on one day of the week.
@Model
final class DayPlan {
    var weekdayRaw: Int
    var careTypeRaw: String
    var activity: String
    var child: Child?

    init(weekday: Weekday, careType: CareType = .atHome, activity: String = "") {
        self.weekdayRaw = weekday.rawValue
        self.careTypeRaw = careType.rawValue
        self.activity = activity
    }

    var weekday: Weekday {
        Weekday(rawValue: weekdayRaw) ?? .monday
    }

    var careType: CareType {
        get { CareType(rawValue: careTypeRaw) ?? .atHome }
        set { careTypeRaw = newValue.rawValue }
    }
}

// MARK: - Key dates

/// A one-off dated event: school fete, photo day, excursion, pupil-free
/// day, Book Week dress-up… Optionally tied to one child, with an
/// optional reminder notification.
@Model
final class FamilyEvent {
    var title: String
    var date: Date
    var notes: String
    var reminderEnabled: Bool
    // Stable ID for the scheduled notification so we can cancel/replace it.
    var reminderID: String
    var child: Child?

    init(title: String, date: Date, notes: String = "",
         reminderEnabled: Bool = false, child: Child? = nil) {
        self.title = title
        self.date = date
        self.notes = notes
        self.reminderEnabled = reminderEnabled
        self.reminderID = UUID().uuidString
        self.child = child
    }

    var isUpcoming: Bool {
        date >= Calendar.current.startOfDay(for: .now)
    }

    var daysAway: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: .now),
            to: Calendar.current.startOfDay(for: date)
        ).day ?? 0
    }
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
