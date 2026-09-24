import Foundation
import SwiftData

final class CreateProfileViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var mobileNumber = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    @Published var showValidationErrors = false

    /// Backward compatibility alias for fullName
    var firstName: String {
        get { fullName }
        set { fullName = newValue }
    }

    private let consentManager: ConsentIntegrationProtocol

    init(consentManager: ConsentIntegrationProtocol = ConveyGridConsentManager.shared) {
        self.consentManager = consentManager
    }

    // MARK: - Validation

    var fullNameError: String? {
        if fullName.isEmpty {
            return showValidationErrors ? "Please enter your full name" : nil
        }
        return Validators.isValidName(fullName) ? nil : "Full name must be at least 2 characters"
    }

    var firstNameError: String? {
        fullNameError
    }

    var emailError: String? {
        if email.isEmpty {
            return showValidationErrors ? "Please enter your email address" : nil
        }
        return Validators.isValidEmail(email) ? nil : "Please enter a valid email address"
    }

    var mobileError: String? {
        if mobileNumber.isEmpty {
            return showValidationErrors ? "Please enter your mobile number" : nil
        }
        return Validators.isValidMobile(mobileNumber) ? nil : "Please enter a valid mobile number (10-15 digits)"
    }

    var isFormValid: Bool {
        Validators.isValidName(fullName) &&
        Validators.isValidEmail(email) &&
        Validators.isValidMobile(mobileNumber)
    }

    // MARK: - Profile Creation

    func createProfile(modelContext: ModelContext, onSuccess: (() -> Void)? = nil) {
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedMobile = mobileNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isFormValid else {
            showValidationErrors = true
            print("[CreateProfile] ⚠️ Continue clicked but form is incomplete/invalid: fullName='\(trimmedName)', email='\(trimmedEmail)', mobile='\(trimmedMobile)'")
            return
        }

        print("[CreateProfile] ▶️ Continue clicked with valid form: fullName='\(trimmedName)', email='\(trimmedEmail)', mobile='\(trimmedMobile)'")

        isLoading = true
        showError = false
        errorMessage = ""

        Task { @MainActor in
            do {
                // 1. Capture consent first via SDK
                try await consentManager.captureConsent(
                    fullName: trimmedName,
                    email: trimmedEmail,
                    mobile: trimmedMobile
                )

                // 2. Only persist the profile if consent was successfully granted/captured
                let profile = UserProfile(
                    fullName: trimmedName,
                    email: trimmedEmail,
                    mobileNumber: trimmedMobile
                )
                modelContext.insert(profile)
                try modelContext.save()

                isLoading = false
                onSuccess?()
                // Profile is saved — ContentView will detect it via @Query and switch to Dashboard
            } catch {
                // Do not save profile and do not navigate to Dashboard
                print("[CreateProfile] Consent capture error (blocking): \(error.localizedDescription)")
                isLoading = false

                let isCancelled = (error as? ConsentError) == .cancelled ||
                                  error.localizedDescription.lowercased().contains("cancelled") ||
                                  error.localizedDescription.lowercased().contains("dismissed")

                if isCancelled {
                    // User dismissed or cancelled the consent sheet: smoothly reset button state so they can try again
                    showError = false
                    errorMessage = ""
                } else {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
