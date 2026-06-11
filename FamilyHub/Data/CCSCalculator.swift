import Foundation

// Child Care Subsidy estimate based on the published 2025–26 rates
// (effective 7 July 2025) and the "3-Day Guarantee" hours that started
// 5 January 2026. Rates are indexed every July — update these constants
// (or fetch from a server) each financial year.
//
// This is an ESTIMATE ONLY. The real entitlement is decided by Services
// Australia and includes things this MVP ignores (higher rate for 2nd+
// child under 6, apportioned hours across sessions, annual reconciliation).
enum CCSRates {
    static let financialYearLabel = "2025–26"

    /// Family income at or below this gets the maximum 90% rate.
    static let lowerIncomeThreshold: Double = 85_279
    static let maxSubsidyPercent: Double = 90
    /// Rate drops 1 percentage point for every $5,000 over the threshold.
    static let taperIncomeStep: Double = 5_000

    /// CCS only subsidises fees up to these hourly caps.
    static let hourlyCapCentreBased: Double = 14.63   // below school age
    static let hourlyCapFamilyDayCare: Double = 13.56

    /// Services Australia withholds 5% of payments until tax-time reconciliation.
    static let withholdingPercent: Double = 5
}

enum CCSCareType: String, CaseIterable, Identifiable {
    case centreBased = "Centre Based Day Care"
    case familyDayCare = "Family Day Care"

    var id: String { rawValue }

    var hourlyCap: Double {
        switch self {
        case .centreBased: return CCSRates.hourlyCapCentreBased
        case .familyDayCare: return CCSRates.hourlyCapFamilyDayCare
        }
    }
}

/// Subsidised hours per fortnight under the rules from 5 January 2026.
enum SubsidisedHours: Int, CaseIterable, Identifiable {
    case threeDayGuarantee = 72
    case fullActivity = 100

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .threeDayGuarantee: return "72 hrs (3-Day Guarantee)"
        case .fullActivity: return "100 hrs (meets activity test)"
        }
    }
}

struct CCSEstimate {
    let subsidyPercent: Double
    let fortnightlyFee: Double
    let fortnightlySubsidy: Double
    let fortnightlyGap: Double

    var weeklyGap: Double { fortnightlyGap / 2 }
}

enum CCSCalculator {
    static func subsidyPercent(familyIncome: Double) -> Double {
        guard familyIncome > CCSRates.lowerIncomeThreshold else {
            return CCSRates.maxSubsidyPercent
        }
        let over = familyIncome - CCSRates.lowerIncomeThreshold
        let percent = CCSRates.maxSubsidyPercent - over / CCSRates.taperIncomeStep
        return max(0, percent)
    }

    static func estimate(
        familyIncome: Double,
        careType: CCSCareType,
        daysPerWeek: Int,
        hoursPerSession: Double,
        dailyFee: Double,
        subsidisedHours: SubsidisedHours
    ) -> CCSEstimate {
        let percent = subsidyPercent(familyIncome: familyIncome)

        let fortnightlyHours = Double(daysPerWeek) * hoursPerSession * 2
        let fortnightlyFee = dailyFee * Double(daysPerWeek) * 2

        guard fortnightlyHours > 0, dailyFee > 0 else {
            return CCSEstimate(subsidyPercent: percent, fortnightlyFee: 0,
                               fortnightlySubsidy: 0, fortnightlyGap: 0)
        }

        let hourlyFee = dailyFee / hoursPerSession
        // The subsidy applies to the lower of your fee and the hourly cap,
        // and only up to your subsidised hours for the fortnight.
        let subsidisableRate = min(hourlyFee, careType.hourlyCap)
        let coveredHours = min(fortnightlyHours, Double(subsidisedHours.rawValue))
        var subsidy = coveredHours * subsidisableRate * (percent / 100)
        subsidy *= 1 - CCSRates.withholdingPercent / 100

        return CCSEstimate(
            subsidyPercent: percent,
            fortnightlyFee: fortnightlyFee,
            fortnightlySubsidy: subsidy,
            fortnightlyGap: max(0, fortnightlyFee - subsidy)
        )
    }
}
