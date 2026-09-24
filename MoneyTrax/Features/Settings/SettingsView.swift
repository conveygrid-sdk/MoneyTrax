import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                if let profile {
                    Section {
                        NavigationLink {
                            EditProfileView(profile: profile)
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.12))
                                        .frame(width: 48, height: 48)
                                    Text(String(profile.firstName.prefix(1)).uppercased())
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(profile.firstName)
                                        .font(.body.weight(.medium))
                                    Text(profile.email)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .accessibilityIdentifier("profileRow")
                    }
                } else {
                    Section {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.12))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.title3)
                                    .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Guest User")
                                    .font(.body.weight(.medium))
                                Text("Tap to create profile & unlock unlimited tracking")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button("Create") {
                                appState.showCreateProfileSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // App settings
                Section("Manage") {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("Categories", systemImage: "tag.fill")
                    }

                    NavigationLink {
                        BudgetView()
                    } label: {
                        Label("Budget", systemImage: "target")
                    }

                    NavigationLink {
                        CurrencySettingsView()
                    } label: {
                        Label("Currency", systemImage: "indianrupeesign.circle")
                    }

                    NavigationLink {
                        PaymentMethodsInfoView()
                    } label: {
                        Label("Payment Methods", systemImage: "creditcard.fill")
                    }
                }

                // Info
                Section("Information") {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy", systemImage: "hand.raised.fill")
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About MoneyTrax", systemImage: "info.circle.fill")
                    }
                }

                // Danger zone
                Section {
                    NavigationLink {
                        DeleteProfileView()
                    } label: {
                        Label(profile != nil ? "Delete Profile" : "Reset Guest Data", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                    .accessibilityIdentifier("deleteProfileRow")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Payment Methods Info

struct PaymentMethodsInfoView: View {
    var body: some View {
        List {
            ForEach(PaymentMethod.allCases) { method in
                HStack(spacing: 14) {
                    Image(systemName: method.icon)
                        .font(.title3)
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                        .frame(width: 36)
                    Text(method.rawValue)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
    }
}
