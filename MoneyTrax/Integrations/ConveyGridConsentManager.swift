import Foundation
import UIKit
import SammatiNoticeSDK

/// Concrete implementation of `ConsentIntegrationProtocol` integrating the official ConveyGrid SDK (`SammatiNoticeSDK`).
///
/// Handles SDK initialization, theming, top view-controller discovery,
/// sheet dismissal detection, and capturing user consent with Full Name, Email, and Mobile Number.
final class ConveyGridConsentManager: ConsentIntegrationProtocol {
    static let shared = ConveyGridConsentManager()

    // MARK: - Configurable Properties

    var clientId: String = ConveyGridConfig.defaultClientId
    var origin: String = ConveyGridConfig.defaultOrigin
    var noticeCode: String = ConveyGridConfig.defaultNoticeCode
    var environment: SammatiEnvironment = .sandbox

    private init() {}

    // MARK: - Configuration

    /// Configures the SammatiNotice SDK.
    /// Can be called during application launch with optional custom overrides.
    func configure() {
        configure(
            clientId: UserDefaults.standard.string(forKey: "ConveyGrid_ClientId") ?? clientId,
            origin: UserDefaults.standard.string(forKey: "ConveyGrid_Origin") ?? origin,
            environment: environment,
            noticeCode: UserDefaults.standard.string(forKey: "ConveyGrid_NoticeCode") ?? noticeCode
        )
    }

    /// Configures the SammatiNotice SDK with explicit parameters.
    func configure(
        clientId: String,
        origin: String,
        environment: SammatiEnvironment = .sandbox,
        noticeCode: String = ConveyGridConfig.defaultNoticeCode
    ) {
        self.clientId = clientId
        self.origin = origin
        self.environment = environment
        self.noticeCode = noticeCode

        let theme = NoticeTheme(
            primaryColor: "#2E57F5",
            secondaryColor: "#10B981",
            fontFamily: "System"
        )

        SammatiNotice.configure(
            SammatiConfiguration(
                clientId: clientId,
                origin: origin,
                environment: environment,
                theme: theme,
                debugMode: true
            )
        )

        print("[ConveyGridConsentManager] Configured SammatiNoticeSDK (Client: \(clientId), Origin: \(origin), Env: \(environment))")
    }

    // MARK: - Consent Capture

    /// Captures consent using the user's Full Name, Email Address, and Mobile Number.
    ///
    /// - Parameters:
    ///   - fullName: The user's full name
    ///   - email: The user's email address
    ///   - mobile: The user's mobile number
    @MainActor
    func captureConsent(fullName: String, email: String, mobile: String) async throws {
        print("[ConveyGridConsentManager] Capturing consent for: \(fullName), \(email), \(mobile)")

        // Ensure software keyboard is dismissed prior to presenting the UIKit consent modal
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        try? await Task.sleep(nanoseconds: 50_000_000)

        guard let presenter = getTopViewController() else {
            print("[ConveyGridConsentManager] ❌ Failed to locate top UIViewController")
            throw SammatiSDKError.serverError("No active view controller found to present consent notice.")
        }

        let options = ConsentOptions(
            noticeCode: noticeCode,
            email: email.isEmpty ? nil : email,
            mobile: mobile.isEmpty ? nil : mobile,
            fullName: fullName.isEmpty ? nil : fullName,
            theme: NoticeTheme(
                primaryColor: "#2E57F5",
                secondaryColor: "#10B981"
            )
        )

        do {
            let result = try await SammatiNotice.captureConsent(
                options: options,
                presenter: presenter
            )
            print("[ConveyGridConsentManager] Consent completed: status=\(result.status ?? "unknown"), showNotice=\(result.showNotice), allMandatoryGranted=\(result.allMandatoryGranted), artifactId=\(result.artifactId ?? "none")")
        } catch {
            print("[ConveyGridConsentManager] Consent capture error: \(error.localizedDescription)")
            if let sdkError = error as? SammatiSDKError, case .cancelled = sdkError {
                throw ConsentError.cancelled
            }
            throw error
        }
    }

    // MARK: - Top View Controller Resolver

    @MainActor
    private func getTopViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let activeScene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        guard let scene = activeScene else { return nil }

        // Filter out keyboard, text effects, and remote overlay windows
        let candidateWindows = scene.windows.filter { window in
            let className = String(describing: type(of: window))
            return !className.contains("Keyboard") && !className.contains("TextEffects")
        }

        let targetWindow = candidateWindows.first(where: { $0.isKeyWindow })
            ?? candidateWindows.first
            ?? scene.windows.first

        return findTop(from: targetWindow?.rootViewController)
    }

    @MainActor
    private func findTop(from root: UIViewController?) -> UIViewController? {
        if let nav = root as? UINavigationController {
            return findTop(from: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return findTop(from: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController, !presented.isBeingDismissed {
            return findTop(from: presented)
        }
        return root
    }
}

