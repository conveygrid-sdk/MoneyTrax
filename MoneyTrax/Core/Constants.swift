import Foundation

// MARK: - Default Categories

struct CategoryInfo {
    let name: String
    let icon: String
}

enum DefaultCategories {
    static let all: [CategoryInfo] = [
        CategoryInfo(name: "Food", icon: "fork.knife"),
        CategoryInfo(name: "Groceries", icon: "cart.fill"),
        CategoryInfo(name: "Shopping", icon: "bag.fill"),
        CategoryInfo(name: "Fuel", icon: "fuelpump.fill"),
        CategoryInfo(name: "Travel", icon: "airplane"),
        CategoryInfo(name: "Rent", icon: "house.fill"),
        CategoryInfo(name: "Utilities", icon: "bolt.fill"),
        CategoryInfo(name: "Entertainment", icon: "film.fill"),
        CategoryInfo(name: "Health", icon: "heart.fill"),
        CategoryInfo(name: "Education", icon: "graduationcap.fill"),
        CategoryInfo(name: "Subscriptions", icon: "repeat"),
        CategoryInfo(name: "Insurance", icon: "shield.fill"),
        CategoryInfo(name: "Other", icon: "ellipsis.circle.fill"),
    ]

    static func icon(for categoryName: String) -> String {
        all.first(where: { $0.name == categoryName })?.icon ?? "tag.fill"
    }
}

// MARK: - App Constants

enum AppConstants {
    static let appName = "MoneyTrax"
    static let appTagline = "Your simple daily expense tracker."
    static let defaultCurrency = "₹"
    static let bundleIdentifier = "com.rysun.dailyexpensetracker"

    static let supportedCurrencies: [(symbol: String, name: String)] = [
        ("₹", "Indian Rupee (INR)"),
        ("$", "US Dollar (USD)"),
        ("€", "Euro (EUR)"),
        ("£", "British Pound (GBP)"),
        ("¥", "Japanese Yen (JPY)"),
        ("A$", "Australian Dollar (AUD)"),
        ("C$", "Canadian Dollar (CAD)"),
    ]

    static let defaultIncomeSources = [
        "Salary",
        "Freelance",
        "Business",
        "Investment",
        "Rental",
        "Gift",
        "Refund",
        "Other",
    ]
}

// MARK: - ConveyGrid Configuration

enum ConveyGridConfig {
    static let defaultClientId = "samapp_KfYEdKnCYouH2hOuJLwOF3vRp5VGU1T-"
    static let defaultOrigin = "https://conveygridapidev.rysun.in/"
    static let defaultNoticeCode = "NOTICE_001"
}
