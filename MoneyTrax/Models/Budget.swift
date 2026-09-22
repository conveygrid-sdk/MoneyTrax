import Foundation
import SwiftData

@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var month: Int
    var year: Int
    var amount: Double
    var category: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        month: Int,
        year: Int,
        amount: Double,
        category: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.month = month
        self.year = year
        self.amount = amount
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
