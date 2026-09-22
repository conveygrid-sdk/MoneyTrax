import Foundation
import SwiftData

final class UserProfileRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetch() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try? modelContext.fetch(descriptor).first
    }

    func save(_ profile: UserProfile) throws {
        modelContext.insert(profile)
        try modelContext.save()
    }

    func update(_ profile: UserProfile, firstName: String, email: String, mobileNumber: String, currencySymbol: String? = nil) throws {
        profile.firstName = firstName
        profile.email = email
        profile.mobileNumber = mobileNumber
        if let currency = currencySymbol {
            profile.currencySymbol = currency
        }
        profile.updatedAt = Date()
        try modelContext.save()
    }

    func update(_ profile: UserProfile, fullName: String, email: String, mobileNumber: String, currencySymbol: String? = nil) throws {
        try update(profile, firstName: fullName, email: email, mobileNumber: mobileNumber, currencySymbol: currencySymbol)
    }

    func updateCurrency(_ profile: UserProfile, symbol: String) throws {
        profile.currencySymbol = symbol
        profile.updatedAt = Date()
        try modelContext.save()
    }

    func delete(_ profile: UserProfile) throws {
        modelContext.delete(profile)
        try modelContext.save()
    }

    func deleteAllData() throws {
        // Delete all user data
        try modelContext.delete(model: UserProfile.self)
        try modelContext.delete(model: Expense.self)
        try modelContext.delete(model: Income.self)
        try modelContext.delete(model: Budget.self)

        // Delete only user-created categories, keep defaults
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate { !$0.isDefault }
        )
        let customCategories = (try? modelContext.fetch(descriptor)) ?? []
        for cat in customCategories {
            modelContext.delete(cat)
        }

        try modelContext.save()
    }
}
