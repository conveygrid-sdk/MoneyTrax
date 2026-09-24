import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query private var incomes: [Income]
    @Query private var profiles: [UserProfile]
    @Query private var categories: [ExpenseCategory]

    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var showFilters = false
    @State private var sortByAmount = false

    private var isGuest: Bool { profiles.isEmpty }
    private var totalTransactions: Int { expenses.count + incomes.count }
    private var isLimitReached: Bool { isGuest && totalTransactions >= AppState.guestTransactionLimit }
    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    private var filteredExpenses: [Expense] {
        var result = expenses

        if !searchText.isEmpty {
            result = result.filter {
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                $0.note.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if sortByAmount {
            result = result.sorted { $0.amount > $1.amount }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            Group {
                if expenses.isEmpty {
                    emptyState
                } else {
                    List {
                        // Filter chips
                        if !categories.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    filterChip("All", isSelected: selectedCategory == nil) {
                                        selectedCategory = nil
                                    }
                                    ForEach(categories) { cat in
                                        filterChip(cat.name, isSelected: selectedCategory == cat.name) {
                                            selectedCategory = selectedCategory == cat.name ? nil : cat.name
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }

                        ForEach(filteredExpenses) { expense in
                            NavigationLink {
                                ExpenseDetailView(expense: expense)
                            } label: {
                                expenseRow(expense)
                            }
                        }
                        .onDelete(perform: deleteExpenses)
                    }
                    .searchable(text: $searchText, prompt: "Search expenses")
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if isLimitReached {
                            appState.showCreateProfileSheet = true
                        } else {
                            appState.showAddExpenseSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                    }
                    .accessibilityIdentifier("addExpenseToolbar")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            sortByAmount = false
                        } label: {
                            Label("Sort by Date", systemImage: sortByAmount ? "" : "checkmark")
                        }
                        Button {
                            sortByAmount = true
                        } label: {
                            Label("Sort by Amount", systemImage: sortByAmount ? "checkmark" : "")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
        }
    }

    private func expenseRow(_ expense: Expense) -> some View {
        HStack(spacing: 14) {
            Image(systemName: expense.categoryIcon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Color.expenseRed)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 6) {
                    Text(expense.date.shortDayMonth)
                    if !expense.note.isEmpty {
                        Text("·")
                        Text(expense.note)
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(expense.amount.currencyFormatted(symbol: currency))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.expenseRed)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "receipt")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("No Expenses Yet")
                .font(.title3.weight(.semibold))
            Text("Tap the + button to add your first expense")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                appState.showAddExpenseSheet = true
            } label: {
                Label("Add Expense", systemImage: "plus")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.18, green: 0.34, blue: 0.96))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(40)
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color(red: 0.18, green: 0.34, blue: 0.96) : Color.elevatedBackground)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expense = filteredExpenses[index]
            modelContext.delete(expense)
        }
        try? modelContext.save()
    }
}
