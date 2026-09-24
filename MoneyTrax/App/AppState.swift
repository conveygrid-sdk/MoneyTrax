import SwiftUI

@Observable
final class AppState {
    var selectedTab: AppTab = .home
    var showAddExpenseSheet = false
    var showAddIncomeSheet = false
    var showAddActionSheet = false
    var showCreateProfileSheet = false

    static let guestTransactionLimit = 3

    var hasSkippedProfileCreation: Bool = UserDefaults.standard.bool(forKey: "hasSkippedProfileCreation") {
        didSet {
            UserDefaults.standard.set(hasSkippedProfileCreation, forKey: "hasSkippedProfileCreation")
        }
    }

    func skipProfileCreation() {
        hasSkippedProfileCreation = true
        selectedTab = .home
    }

    func resetSkippedProfileCreation() {
        hasSkippedProfileCreation = false
        selectedTab = .home
        UserDefaults.standard.removeObject(forKey: "hasSkippedProfileCreation")
    }

    enum AppTab: Int, CaseIterable {
        case home = 0
        case transactions = 1
        case add = 2
        case reports = 3
        case settings = 4

        var title: String {
            switch self {
            case .home: return "Home"
            case .transactions: return "Transactions"
            case .add: return "Add"
            case .reports: return "Reports"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .transactions: return "list.bullet.rectangle.fill"
            case .add: return "plus.circle.fill"
            case .reports: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
}
