import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))

                    Text("MoneyTrax")
                        .font(.title2.weight(.bold))

                    Text("Your simple daily expense tracker")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowBackground(Color.clear)
            }

            Section("About") {
                Text("MoneyTrax helps you track your daily expenses and income with an intuitive interface. All your financial data is stored locally on your device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }

            Section("Features") {
                featureItem(icon: "chart.pie.fill", title: "Expense Tracking", description: "Track expenses by category")
                featureItem(icon: "arrow.down.circle.fill", title: "Income Management", description: "Record multiple income sources")
                featureItem(icon: "chart.bar.fill", title: "Reports & Charts", description: "Visual spending insights")
                featureItem(icon: "target", title: "Budget Planning", description: "Set and track monthly budgets")
                featureItem(icon: "lock.shield.fill", title: "Privacy First", description: "Data stored locally on device")
            }

            Section("Legal") {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text("Made with ❤️ for everyday budgeting")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
