import Foundation
import SwiftData

final class ExpenseRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD

    func fetchAll(
        searchText: String = "",
        category: String? = nil,
        paymentMethod: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        sortByAmount: Bool = false,
        ascending: Bool = false
    ) -> [Expense] {
        var descriptor = FetchDescriptor<Expense>()

        var predicates: [Predicate<Expense>] = []

        if let category, !category.isEmpty {
            predicates.append(#Predicate { $0.category == category })
        }

        if let paymentMethod, !paymentMethod.isEmpty {
            predicates.append(#Predicate { $0.paymentMethod == paymentMethod })
        }

        if let startDate {
            predicates.append(#Predicate { $0.date >= startDate })
        }

        if let endDate {
            predicates.append(#Predicate { $0.date <= endDate })
        }

        if !searchText.isEmpty {
            let search = searchText
            predicates.append(#Predicate {
                $0.category.localizedStandardContains(search) ||
                $0.note.localizedStandardContains(search)
            })
        }

        if predicates.count == 1 {
            descriptor.predicate = predicates[0]
        } else if predicates.count > 1 {
            // Combine predicates manually based on what's filtered
            if let cat = category, !cat.isEmpty, !searchText.isEmpty {
                let search = searchText
                descriptor.predicate = #Predicate {
                    $0.category == cat &&
                    ($0.category.localizedStandardContains(search) ||
                     $0.note.localizedStandardContains(search))
                }
            }
        }

        if sortByAmount {
            descriptor.sortBy = ascending ?
                [SortDescriptor(\.amount, order: .forward)] :
                [SortDescriptor(\.amount, order: .reverse)]
        } else {
            descriptor.sortBy = ascending ?
                [SortDescriptor(\.date, order: .forward)] :
                [SortDescriptor(\.date, order: .reverse)]
        }

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchForMonth(month: Int, year: Int) -> [Expense] {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.month = month
        startComponents.year = year
        startComponents.day = 1

        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return []
        }

        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchRecent(limit: Int = 5) -> [Expense] {
        var descriptor = FetchDescriptor<Expense>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func totalForMonth(month: Int, year: Int) -> Double {
        fetchForMonth(month: month, year: year).reduce(0) { $0 + $1.amount }
    }

    func totalByCategory(month: Int, year: Int) -> [(category: String, icon: String, total: Double)] {
        let expenses = fetchForMonth(month: month, year: year)
        var grouped: [String: (icon: String, total: Double)] = [:]

        for expense in expenses {
            let existing = grouped[expense.category] ?? (icon: expense.categoryIcon, total: 0)
            grouped[expense.category] = (icon: existing.icon, total: existing.total + expense.amount)
        }

        return grouped.map { (category: $0.key, icon: $0.value.icon, total: $0.value.total) }
            .sorted { $0.total > $1.total }
    }

    func dailyTotals(month: Int, year: Int) -> [(day: Int, total: Double)] {
        let expenses = fetchForMonth(month: month, year: year)
        var daily: [Int: Double] = [:]
        let calendar = Calendar.current

        for expense in expenses {
            let day = calendar.component(.day, from: expense.date)
            daily[day, default: 0] += expense.amount
        }

        return daily.map { (day: $0.key, total: $0.value) }
            .sorted { $0.day < $1.day }
    }

    func save(_ expense: Expense) throws {
        modelContext.insert(expense)
        try modelContext.save()
    }

    func update(_ expense: Expense) throws {
        expense.updatedAt = Date()
        try modelContext.save()
    }

    func delete(_ expense: Expense) throws {
        modelContext.delete(expense)
        try modelContext.save()
    }
}
