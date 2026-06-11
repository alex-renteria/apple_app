import SwiftUI

// Child Care Subsidy estimator. All inputs persist via @AppStorage so
// parents see their own numbers every time they open the app.
struct CCSEstimatorView: View {
    @AppStorage("ccsIncome") private var familyIncome = 120_000.0
    @AppStorage("ccsDaysPerWeek") private var daysPerWeek = 3
    @AppStorage("ccsHoursPerSession") private var hoursPerSession = 10.0
    @AppStorage("ccsDailyFee") private var dailyFee = 140.0
    @AppStorage("ccsCareType") private var careTypeRaw = CCSCareType.centreBased.rawValue
    @AppStorage("ccsHours") private var subsidisedHoursRaw = SubsidisedHours.threeDayGuarantee.rawValue

    private var careType: CCSCareType {
        CCSCareType(rawValue: careTypeRaw) ?? .centreBased
    }

    private var subsidisedHours: SubsidisedHours {
        SubsidisedHours(rawValue: subsidisedHoursRaw) ?? .threeDayGuarantee
    }

    private var estimate: CCSEstimate {
        CCSCalculator.estimate(
            familyIncome: familyIncome,
            careType: careType,
            daysPerWeek: daysPerWeek,
            hoursPerSession: hoursPerSession,
            dailyFee: dailyFee,
            subsidisedHours: subsidisedHours
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your family") {
                    LabeledContent("Combined income") {
                        TextField("Income", value: $familyIncome, format: .currency(code: "AUD").precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Subsidised hours", selection: $subsidisedHoursRaw) {
                        ForEach(SubsidisedHours.allCases) { hours in
                            Text(hours.label).tag(hours.rawValue)
                        }
                    }
                }

                Section("Your care") {
                    Picker("Care type", selection: $careTypeRaw) {
                        ForEach(CCSCareType.allCases) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                    Stepper("Days per week: \(daysPerWeek)", value: $daysPerWeek, in: 1...5)
                    Stepper("Session length: \(hoursPerSession, specifier: "%.0f") hrs",
                            value: $hoursPerSession, in: 6...12, step: 0.5)
                    LabeledContent("Daily fee") {
                        TextField("Fee", value: $dailyFee, format: .currency(code: "AUD").precision(.fractionLength(0)))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Your estimate") {
                    LabeledContent("Subsidy rate") {
                        Text("\(estimate.subsidyPercent, specifier: "%.1f")%")
                            .font(.headline)
                    }
                    LabeledContent("Fees per fortnight") {
                        Text(estimate.fortnightlyFee, format: .currency(code: "AUD").precision(.fractionLength(0)))
                    }
                    LabeledContent("CCS pays (approx.)") {
                        Text(estimate.fortnightlySubsidy, format: .currency(code: "AUD").precision(.fractionLength(0)))
                            .foregroundStyle(.green)
                    }
                    LabeledContent("Your gap per fortnight") {
                        Text(estimate.fortnightlyGap, format: .currency(code: "AUD").precision(.fractionLength(0)))
                            .font(.headline)
                            .foregroundStyle(.tint)
                    }
                    LabeledContent("Your gap per week") {
                        Text(estimate.weeklyGap, format: .currency(code: "AUD").precision(.fractionLength(0)))
                    }
                } footer: {
                    Text("Estimate only, using published \(CCSRates.financialYearLabel) rates and the 3-Day Guarantee from 5 Jan 2026. Includes the standard 5% withholding. Doesn't include the higher rate for a 2nd child under 6. Confirm your actual entitlement with Services Australia.")
                }
            }
            .navigationTitle("CCS Estimator")
        }
    }
}

#Preview {
    CCSEstimatorView()
}
