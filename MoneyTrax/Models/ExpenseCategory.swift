import Foundation
import SwiftData

@Model
final class ExpenseCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var isDefault: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
}
