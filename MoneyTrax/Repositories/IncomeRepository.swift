import Foundation
import SwiftData

final class IncomeRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll(
        searchText: String = "",
        startDate: Date? = nil,
        endDate: Date? = nil,
        sortByAmount: Bool = false,
        ascending: Bool = false
    ) -> [Income] {
        var descriptor = FetchDescriptor<Income>()

        if !searchText.isEmpty {
            let search = searchText
            descriptor.predicate = #Predicate {
                $0.source.localizedStandardContains(search) ||
                $0.note.localizedStandardContains(search)
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

    func fetchForMonth(month: Int, year: Int) -> [Income] {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.month = month
        startComponents.year = year
        startComponents.day = 1

        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return []
        }

        let descriptor = FetchDescriptor<Income>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchRecent(limit: Int = 5) -> [Income] {
        var descriptor = FetchDescriptor<Income>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func totalForMonth(month: Int, year: Int) -> Double {
        fetchForMonth(month: month, year: year).reduce(0) { $0 + $1.amount }
    }

    func save(_ income: Income) throws {
        modelContext.insert(income)
        try modelContext.save()
    }

    func update(_ income: Income) throws {
        income.updatedAt = Date()
        try modelContext.save()
    }

    func delete(_ income: Income) throws {
        modelContext.delete(income)
        try modelContext.save()
    }
}
