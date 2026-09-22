import SwiftUI

extension Color {
    // MARK: - Brand Colors

    static let appPrimary = Color("AppPrimary", bundle: nil)
    static let appSecondary = Color("AppSecondary", bundle: nil)

    // Fallback computed colors when asset catalog colors aren't available
    static let appPrimaryFallback = Color(red: 0.18, green: 0.34, blue: 0.96)    // #2E57F5
    static let appSecondaryFallback = Color(red: 0.40, green: 0.85, blue: 0.72)   // #66D9B8

    // MARK: - Semantic Colors

    static let incomeGreen = Color(red: 0.20, green: 0.78, blue: 0.55)           // #33C78C
    static let expenseRed = Color(red: 0.95, green: 0.33, blue: 0.37)            // #F2545E
    static let warningYellow = Color(red: 1.0, green: 0.76, blue: 0.22)          // #FFC238
    static let budgetOrange = Color(red: 0.98, green: 0.58, blue: 0.22)          // #FA9438

    // MARK: - Surface Colors

    static let cardBackground = Color(.systemBackground)
    static let elevatedBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    // MARK: - Gradient

    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.18, green: 0.34, blue: 0.96),
            Color(red: 0.36, green: 0.47, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let incomeGradient = LinearGradient(
        colors: [
            Color(red: 0.20, green: 0.78, blue: 0.55),
            Color(red: 0.30, green: 0.88, blue: 0.65)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let expenseGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.33, blue: 0.37),
            Color(red: 0.98, green: 0.45, blue: 0.48)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let welcomeGradient = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.12, blue: 0.28),
            Color(red: 0.18, green: 0.34, blue: 0.96)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - View Modifiers

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }

    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}
