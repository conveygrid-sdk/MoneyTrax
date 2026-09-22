import SwiftUI
import SwiftData

@main
struct MoneyTraxApp: App {
    let modelContainer: ModelContainer
    @State private var appState = AppState()

    init() {
        do {
            let schema = Schema([
                UserProfile.self,
                Expense.self,
                Income.self,
                ExpenseCategory.self,
                Budget.self
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }

        // Initialize ConveyGrid Consent SDK
        ConveyGridConsentManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onAppear {
                    seedDefaultCategoriesIfNeeded()
                }
        }
        .modelContainer(modelContainer)
    }

    private func seedDefaultCategoriesIfNeeded() {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<ExpenseCategory>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        for category in DefaultCategories.all {
            let model = ExpenseCategory(
                name: category.name,
                icon: category.icon,
                isDefault: true
            )
            context.insert(model)
        }
        try? context.save()
    }
}
