import Foundation
import SwiftData

final class BudgetRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> [Budget] {
        let descriptor = FetchDescriptor<Budget>(
            sortBy: [
                SortDescriptor(\.year, order: .reverse),
                SortDescriptor(\.month, order: .reverse)
            ]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchForMonth(month: Int, year: Int) -> [Budget] {
        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate { $0.month == month && $0.year == year }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func overallBudget(month: Int, year: Int) -> Budget? {
        let budgets = fetchForMonth(month: month, year: year)
        return budgets.first(where: { $0.category == nil })
    }

    func categoryBudget(month: Int, year: Int, category: String) -> Budget? {
        let budgets = fetchForMonth(month: month, year: year)
        return budgets.first(where: { $0.category == category })
    }

    func save(_ budget: Budget) throws {
        modelContext.insert(budget)
        try modelContext.save()
    }

    func update(_ budget: Budget) throws {
        budget.updatedAt = Date()
        try modelContext.save()
    }

    func upsert(month: Int, year: Int, amount: Double, category: String? = nil) throws {
        if let existing = category != nil ?
            categoryBudget(month: month, year: year, category: category!) :
            overallBudget(month: month, year: year) {
            existing.amount = amount
            existing.updatedAt = Date()
        } else {
            let budget = Budget(month: month, year: year, amount: amount, category: category)
            modelContext.insert(budget)
        }
        try modelContext.save()
    }

    func delete(_ budget: Budget) throws {
        modelContext.delete(budget)
        try modelContext.save()
    }
}
