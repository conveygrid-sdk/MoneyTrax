import Foundation
import SwiftData

final class CategoryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> [ExpenseCategory] {
        let descriptor = FetchDescriptor<ExpenseCategory>(
            sortBy: [
                SortDescriptor(\.name, order: .forward)
            ]
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        return items.sorted { ($0.isDefault ? 0 : 1) < ($1.isDefault ? 0 : 1) }
    }

    func fetchDefaults() -> [ExpenseCategory] {
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate { $0.isDefault },
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchCustom() -> [ExpenseCategory] {
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate { !$0.isDefault },
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func save(_ category: ExpenseCategory) throws {
        modelContext.insert(category)
        try modelContext.save()
    }

    func delete(_ category: ExpenseCategory) throws {
        modelContext.delete(category)
        try modelContext.save()
    }

    func exists(name: String) -> Bool {
        let descriptor = FetchDescriptor<ExpenseCategory>(
            predicate: #Predicate { $0.name == name }
        )
        return ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }
}
