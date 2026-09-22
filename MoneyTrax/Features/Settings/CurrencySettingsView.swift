import SwiftUI
import SwiftData

struct CurrencySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        List {
            Section {
                ForEach(AppConstants.supportedCurrencies, id: \.symbol) { currency in
                    Button {
                        selectCurrency(currency.symbol)
                    } label: {
                        HStack {
                            Text(currency.symbol)
                                .font(.title3.weight(.semibold))
                                .frame(width: 36)

                            Text(currency.name)
                                .foregroundStyle(.primary)

                            Spacer()

                            if profile?.currencySymbol == currency.symbol {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Select Currency")
            } footer: {
                Text("This changes the currency symbol displayed throughout the app. It does not convert amounts.")
            }
        }
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectCurrency(_ symbol: String) {
        guard let profile else { return }
        profile.currencySymbol = symbol
        profile.updatedAt = Date()
        try? modelContext.save()
    }
}
