import SwiftUI
import SwiftData

struct DeleteProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showConfirmation = false
    @State private var confirmText = ""
    @State private var isDeleting = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.red)

            Text("Delete Your Profile")
                .font(.title2.weight(.bold))

            Text("This action will permanently delete all your MoneyTrax data from this device, including:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                deleteItem("Your profile information")
                deleteItem("All expense records")
                deleteItem("All income records")
                deleteItem("Custom categories you created")
                deleteItem("All budget settings")
            }
            .padding(.horizontal, 8)

            Text("Data previously transmitted to the consent service during profile setup may be retained by that service according to their data retention policy.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Spacer()

            Button(role: .destructive) {
                showConfirmation = true
            } label: {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "trash.fill")
                        Text("Delete All Data")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(isDeleting)
            .accessibilityIdentifier("deleteAllDataButton")

            Spacer()
                .frame(height: 20)
        }
        .padding(.horizontal, 28)
        .navigationTitle("Delete Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Are you sure?",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                performDeletion()
            }
        } message: {
            Text("This cannot be undone. All your local MoneyTrax data will be permanently removed.")
        }
    }

    private func deleteItem(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red.opacity(0.7))
                .font(.subheadline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func performDeletion() {
        isDeleting = true

        let repo = UserProfileRepository(modelContext: modelContext)
        do {
            try repo.deleteAllData()
        } catch {
            print("Deletion error: \(error)")
        }

        isDeleting = false
        // ContentView's @Query will detect empty profiles and show Welcome screen
    }
}
