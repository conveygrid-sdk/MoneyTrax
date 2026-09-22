import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var budgets: [Budget]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query private var profiles: [UserProfile]
    @Query private var categories: [ExpenseCategory]

    @State private var showAddBudget = false
    @State private var selectedMonth = Date().monthNumber
    @State private var selectedYear = Date().yearNumber

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    private var currentBudgets: [Budget] {
        budgets.filter { $0.month == selectedMonth && $0.year == selectedYear }
    }

    private var overallBudget: Budget? {
        currentBudgets.first(where: { $0.category == nil })
    }

    private var categoryBudgets: [Budget] {
        currentBudgets.filter { $0.category != nil }
    }

    private var totalMonthlyExpense: Double {
        expenses
            .filter { $0.date.monthNumber == selectedMonth && $0.date.yearNumber == selectedYear }
            .reduce(0) { $0 + $1.amount }
    }

    private func expenseForCategory(_ category: String) -> Double {
        expenses
            .filter {
                $0.category == category &&
                $0.date.monthNumber == selectedMonth &&
                $0.date.yearNumber == selectedYear
            }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Month selector
                    monthSelector

                    // Overall budget
                    if let budget = overallBudget {
                        overallBudgetCard(budget)
                    }

                    // Category budgets
                    if !categoryBudgets.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Budgets")
                                .font(.headline)
                                .padding(.horizontal, 4)

                            ForEach(categoryBudgets) { budget in
                                if let category = budget.category {
                                    categoryBudgetCard(budget, category: category)
                                }
                            }
                        }
                    }

                    if currentBudgets.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.elevatedBackground.ignoresSafeArea())
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                AddBudgetView(month: selectedMonth, year: selectedYear)
            }
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        HStack {
            Button {
                if selectedMonth == 1 { selectedMonth = 12; selectedYear -= 1 }
                else { selectedMonth -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
            }

            Spacer()

            Text(monthYearDisplay)
                .font(.headline)

            Spacer()

            Button {
                if selectedMonth == 12 { selectedMonth = 1; selectedYear += 1 }
                else { selectedMonth += 1 }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }

    private var monthYearDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        components.day = 1
        guard let date = Calendar.current.date(from: components) else { return "" }
        return formatter.string(from: date)
    }

    // MARK: - Overall Budget Card

    private func overallBudgetCard(_ budget: Budget) -> some View {
        let spent = totalMonthlyExpense
        let remaining = budget.amount - spent
        let progress = budget.amount > 0 ? min(spent / budget.amount, 1.5) : 0
        let overBudget = spent > budget.amount

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Budget")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(budget.amount.currencyFormatted(symbol: currency))
                        .font(.title2.weight(.bold))
                }
                Spacer()
                Image(systemName: overBudget ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(overBudget ? Color.expenseRed : Color.incomeGreen)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.elevatedBackground)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor(progress))
                        .frame(width: geo.size.width * min(progress, 1.0), height: 12)
                }
            }
            .frame(height: 12)

            HStack {
                VStack(alignment: .leading) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(spent.currencyFormatted(symbol: currency))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.expenseRed)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(overBudget ? "Over Budget" : "Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(abs(remaining).currencyFormatted(symbol: currency))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(overBudget ? Color.expenseRed : Color.incomeGreen)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Category Budget Card

    private func categoryBudgetCard(_ budget: Budget, category: String) -> some View {
        let spent = expenseForCategory(category)
        let progress = budget.amount > 0 ? min(spent / budget.amount, 1.5) : 0
        let remaining = budget.amount - spent
        let overBudget = spent > budget.amount
        let icon = DefaultCategories.icon(for: category)

        return HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(progressColor(progress))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(spent.currencyFormatted(symbol: currency)) / \(budget.amount.currencyFormatted(symbol: currency))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.elevatedBackground)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor(progress))
                            .frame(width: geo.size.width * min(progress, 1.0), height: 6)
                    }
                }
                .frame(height: 6)

                if overBudget {
                    Text("Over budget by \(abs(remaining).currencyFormatted(symbol: currency))")
                        .font(.caption2)
                        .foregroundStyle(Color.expenseRed)
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private func progressColor(_ progress: Double) -> Color {
        if progress > 1.0 { return .expenseRed }
        if progress > 0.75 { return .warningYellow }
        return .incomeGreen
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No Budgets Set")
                .font(.title3.weight(.semibold))
            Text("Set a monthly budget to track your spending goals")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddBudget = true
            } label: {
                Label("Set Budget", systemImage: "plus")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.18, green: 0.34, blue: 0.96))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Add Budget View

struct AddBudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [ExpenseCategory]
    @Query private var profiles: [UserProfile]

    let month: Int
    let year: Int

    @State private var amountText = ""
    @State private var isOverallBudget = true
    @State private var selectedCategory = ""

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    private var isValid: Bool {
        guard let amount = Double(amountText), amount > 0 else { return false }
        if !isOverallBudget { return !selectedCategory.isEmpty }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text(currency)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("0", text: $amountText)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Budget Amount")
                }

                Section {
                    Toggle("Overall Monthly Budget", isOn: $isOverallBudget)

                    if !isOverallBudget {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select").tag("")
                            ForEach(categories) { cat in
                                Label(cat.name, systemImage: cat.icon).tag(cat.name)
                            }
                        }
                    }
                } header: {
                    Text("Type")
                }
            }
            .navigationTitle("Set Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveBudget() {
        guard let amount = Double(amountText), amount > 0 else { return }

        let category = isOverallBudget ? nil : selectedCategory
        let repo = BudgetRepository(modelContext: modelContext)

        do {
            try repo.upsert(month: month, year: year, amount: amount, category: category)
        } catch {
            print("Failed to save budget: \(error)")
        }

        dismiss()
    }
}
