import Foundation
import SwiftData

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var category: String
    var categoryIcon: String
    var date: Date
    var paymentMethod: String
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        categoryIcon: String = "tag.fill",
        date: Date = Date(),
        paymentMethod: String = PaymentMethod.cash.rawValue,
        note: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.categoryIcon = categoryIcon
        self.date = date
        self.paymentMethod = paymentMethod
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
