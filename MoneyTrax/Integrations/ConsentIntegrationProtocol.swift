import Foundation

/// Protocol that isolates the consent SDK from the rest of the app.
/// Only `ConveyGridConsentManager` knows about the actual SDK.
protocol ConsentIntegrationProtocol {
    /// Configure the SDK at app launch
    func configure()

    /// Capture consent using user profile information
    /// - Parameters:
    ///   - fullName: User's full name
    ///   - email: User's email address
    ///   - mobile: User's mobile number
    @MainActor
    func captureConsent(fullName: String, email: String, mobile: String) async throws

    /// Backward compatibility helper forwarding to captureConsent(fullName:email:mobile:)
    @MainActor
    func captureConsent(firstName: String, email: String, mobile: String) async throws
}

extension ConsentIntegrationProtocol {
    @MainActor
    func captureConsent(firstName: String, email: String, mobile: String) async throws {
        try await captureConsent(fullName: firstName, email: email, mobile: mobile)
    }
}

/// Standardized consent error types exposed to the app layer.
enum ConsentError: LocalizedError, Equatable {
    case cancelled
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Consent collection was cancelled or dismissed."
        case .failed(let message):
            return message
        }
    }
}
