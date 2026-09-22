import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "hand.raised.fill")
                        .font(.title)
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                    Text("Privacy Policy")
                        .font(.title2.weight(.bold))
                    Text("Last updated: September 2026")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Local Storage
                policySection(
                    title: "What MoneyTrax Stores Locally",
                    icon: "iphone",
                    content: """
                    MoneyTrax stores all your financial data locally on your device using Apple's SwiftData framework. This includes:

                    • Your expenses and income entries
                    • Categories you create
                    • Monthly budget settings
                    • Your profile information (name, email, mobile number)
                    • Your preferred currency

                    This data never leaves your device through MoneyTrax itself. All calculations, reports, and transaction history are processed entirely on your iPhone.
                    """
                )

                // Profile Information
                policySection(
                    title: "Personal Information Collected",
                    icon: "person.fill",
                    content: """
                    During profile setup, MoneyTrax collects:

                    • First Name
                    • Email Address
                    • Mobile Number

                    This information is stored locally on your device and is also transmitted to a third-party consent management service during the initial profile setup process for regulatory compliance purposes.
                    """
                )

                // Third-Party Consent
                policySection(
                    title: "Third-Party Data Processing",
                    icon: "arrow.up.forward.circle.fill",
                    content: """
                    MoneyTrax integrates a consent management service that processes your name, email address, and mobile number during the initial profile creation. This data is transmitted to the service provider's servers to fulfill consent and regulatory requirements.

                    This means your personal profile information (name, email, mobile) is not stored solely on your device — it is also processed by the consent management service.

                    MoneyTrax does not use this service for advertising, analytics, or tracking purposes.
                    """
                )

                // No Tracking
                policySection(
                    title: "What MoneyTrax Does NOT Do",
                    icon: "xmark.shield.fill",
                    content: """
                    • Does NOT track your location
                    • Does NOT access your contacts
                    • Does NOT access your photos or camera
                    • Does NOT use advertising SDKs
                    • Does NOT use analytics services
                    • Does NOT share your financial data with third parties
                    • Does NOT require an internet connection for expense tracking
                    """
                )

                // Data Deletion
                policySection(
                    title: "Data Deletion",
                    icon: "trash.fill",
                    content: """
                    You can delete all your locally stored data at any time through Settings → Delete Profile. This will permanently remove:

                    • Your profile information
                    • All expenses and income entries
                    • All custom categories
                    • All budget settings

                    Please note that data previously transmitted to the third-party consent service during profile creation may be retained according to that service's own data retention policy. MoneyTrax cannot guarantee deletion of data held by third-party services.
                    """
                )

                // Contact
                policySection(
                    title: "Questions",
                    icon: "envelope.fill",
                    content: """
                    If you have questions about your data or this privacy policy, please contact us through the App Store listing.
                    """
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                Text(title)
                    .font(.headline)
            }

            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}
