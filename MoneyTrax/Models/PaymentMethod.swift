import Foundation

enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case cash = "Cash"
    case upi = "UPI"
    case card = "Card"
    case bank = "Bank"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .cash: return "banknote.fill"
        case .upi: return "iphone.gen3"
        case .card: return "creditcard.fill"
        case .bank: return "building.columns.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
