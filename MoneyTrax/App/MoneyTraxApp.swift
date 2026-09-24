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

        // Handle automated tab selection for screenshot capture
        if CommandLine.arguments.contains("-reportsTab") {
            let state = AppState()
            state.selectedTab = .reports
            _appState = State(initialValue: state)
        } else if CommandLine.arguments.contains("-transactionsTab") {
            let state = AppState()
            state.selectedTab = .transactions
            _appState = State(initialValue: state)
        } else if CommandLine.arguments.contains("-settingsTab") {
            let state = AppState()
            state.selectedTab = .settings
            _appState = State(initialValue: state)
        } else if CommandLine.arguments.contains("-addExpense") {
            let state = AppState()
            state.showAddExpenseSheet = true
            _appState = State(initialValue: state)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onAppear {
                    seedDefaultCategoriesIfNeeded()
                    seedDemoDataIfNeeded()
                }
        }
        .modelContainer(modelContainer)
    }

    private func seedDemoDataIfNeeded() {
        guard CommandLine.arguments.contains("-seedDemoData") else { return }
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? context.fetch(descriptor), let profile = existing.first {
            profile.firstName = "Alex Morgan"
            profile.email = "alex.morgan@example.com"
            try? context.save()
            return
        }

        if (try? context.fetchCount(descriptor)) == 0 {
            let profile = UserProfile(
                fullName: "Alex Morgan",
                email: "alex.morgan@example.com",
                mobileNumber: "+91 98765 43210",
                currencySymbol: "₹"
            )
            context.insert(profile)

            // Income
            context.insert(Income(amount: 65000, source: "Monthly Salary", date: Date()))
            context.insert(Income(amount: 15000, source: "Freelance Work", date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!))

            // Expenses
            context.insert(Expense(amount: 3200, category: "Dining Out", categoryIcon: "fork.knife", date: Date(), paymentMethod: PaymentMethod.card.rawValue, note: "Family Dinner"))
            context.insert(Expense(amount: 4500, category: "Groceries", categoryIcon: "cart.fill", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, paymentMethod: PaymentMethod.upi.rawValue, note: "Supermarket items"))
            context.insert(Expense(amount: 2100, category: "Utilities", categoryIcon: "bolt.fill", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, paymentMethod: PaymentMethod.bank.rawValue, note: "Electricity bill"))
            context.insert(Expense(amount: 5400, category: "Shopping", categoryIcon: "bag.fill", date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, paymentMethod: PaymentMethod.card.rawValue, note: "New clothes"))
            context.insert(Expense(amount: 850, category: "Transport", categoryIcon: "car.fill", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, paymentMethod: PaymentMethod.upi.rawValue, note: "Cab rides"))
            context.insert(Expense(amount: 999, category: "Entertainment", categoryIcon: "tv.fill", date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, paymentMethod: PaymentMethod.card.rawValue, note: "Streaming subscription"))

            // Budgets
            let month = Date().monthNumber
            let year = Date().yearNumber
            context.insert(Budget(month: month, year: year, amount: 45000, category: nil))
            context.insert(Budget(month: month, year: year, amount: 10000, category: "Groceries"))
            context.insert(Budget(month: month, year: year, amount: 8000, category: "Dining Out"))
            context.insert(Budget(month: month, year: year, amount: 12000, category: "Shopping"))
            context.insert(Budget(month: month, year: year, amount: 5000, category: "Utilities"))

            try? context.save()
        }
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
