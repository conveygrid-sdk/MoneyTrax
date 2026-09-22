import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var email: String
    var mobileNumber: String
    var currencySymbol: String
    var createdAt: Date
    var updatedAt: Date

    var fullName: String {
        get { firstName }
        set { firstName = newValue }
    }

    init(
        id: UUID = UUID(),
        firstName: String,
        email: String,
        mobileNumber: String,
        currencySymbol: String = "₹",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.email = email
        self.mobileNumber = mobileNumber
        self.currencySymbol = currencySymbol
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    convenience init(
        id: UUID = UUID(),
        fullName: String,
        email: String,
        mobileNumber: String,
        currencySymbol: String = "₹",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.init(
            id: id,
            firstName: fullName,
            email: email,
            mobileNumber: mobileNumber,
            currencySymbol: currencySymbol,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
