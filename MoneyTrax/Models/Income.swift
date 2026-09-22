import Foundation
import SwiftData

@Model
final class Income {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var source: String
    var date: Date
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        source: String,
        date: Date = Date(),
        note: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.source = source
        self.date = date
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
