import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]
    @Query private var profiles: [UserProfile]

    @State private var searchText = ""
    @State private var filterType: TransactionFilter = .all
    @State private var sortByAmount = false

    private var isGuest: Bool { profiles.isEmpty }
    private var totalTransactions: Int { expenses.count + incomes.count }
    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expenses"
    }

    struct TransactionItem: Identifiable {
        let id: UUID
        let title: String
        let amount: Double
        let icon: String
        let date: Date
        let isIncome: Bool
        let note: String
        let subtitle: String
    }

    private var allTransactions: [TransactionItem] {
        var items: [TransactionItem] = []

        if filterType != .income {
            items += expenses.map {
                TransactionItem(
                    id: $0.id, title: $0.category, amount: $0.amount,
                    icon: $0.categoryIcon, date: $0.date, isIncome: false,
                    note: $0.note, subtitle: $0.paymentMethod
                )
            }
        }

        if filterType != .expense {
            items += incomes.map {
                TransactionItem(
                    id: $0.id, title: $0.source, amount: $0.amount,
                    icon: "arrow.down.circle.fill", date: $0.date, isIncome: true,
                    note: $0.note, subtitle: "Income"
                )
            }
        }

        // Search filter
        if !searchText.isEmpty {
            items = items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.note.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        if sortByAmount {
            items.sort { $0.amount > $1.amount }
        } else {
            items.sort { $0.date > $1.date }
        }

        return items
    }

    private var groupedByDate: [(date: String, items: [TransactionItem])] {
        var sections: [(date: String, startOfDay: Date, items: [TransactionItem])] = []
        for item in allTransactions {
            let start = Calendar.current.startOfDay(for: item.date)
            let dateStr = item.date.relativeDescription
            if let index = sections.firstIndex(where: { Calendar.current.isDate($0.startOfDay, inSameDayAs: start) }) {
                sections[index].items.append(item)
            } else {
                sections.append((date: dateStr, startOfDay: start, items: [item]))
            }
        }
        return sections.map { (date: $0.date, items: $0.items) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter tabs
                Picker("Filter", selection: $filterType) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if isGuest {
                    HStack(spacing: 8) {
                        Image(systemName: totalTransactions >= AppState.guestTransactionLimit ? "exclamationmark.circle.fill" : "info.circle.fill")
                            .foregroundStyle(totalTransactions >= AppState.guestTransactionLimit ? Color.expenseRed : Color(red: 0.18, green: 0.34, blue: 0.96))
                        Text(totalTransactions >= AppState.guestTransactionLimit ? "Guest limit reached (3/3). Delete or create profile to add more." : "Guest Mode: \(totalTransactions)/\(AppState.guestTransactionLimit) transactions used")
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer()
                        Button("Unlock All") {
                            appState.showCreateProfileSheet = true
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.elevatedBackground)
                }

                if allTransactions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.tertiary)
                        Text("No Transactions Found")
                            .font(.headline)
                        Text(searchText.isEmpty ? "Start adding expenses and income to see them here" : "Try a different search term")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                    Spacer()
                } else {
                    List {
                        ForEach(groupedByDate, id: \.date) { group in
                            Section(group.date) {
                                ForEach(group.items) { item in
                                    transactionRow(item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteTransaction(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Transactions")
            .searchable(text: $searchText, prompt: "Search transactions")
            .toolbar {
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

    private func deleteTransaction(_ item: TransactionItem) {
        if item.isIncome {
            if let income = incomes.first(where: { $0.id == item.id }) {
                modelContext.delete(income)
            }
        } else {
            if let expense = expenses.first(where: { $0.id == item.id }) {
                modelContext.delete(expense)
            }
        }
        try? modelContext.save()
    }

    private func transactionRow(_ item: TransactionItem) -> some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(item.isIncome ? Color.incomeGreen : Color.expenseRed)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 4) {
                    Text(item.subtitle)
                    if !item.note.isEmpty {
                        Text("·")
                        Text(item.note)
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(item.isIncome ? "+" : "-")\(item.amount.currencyFormatted(symbol: currency))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(item.isIncome ? Color.incomeGreen : Color.expenseRed)
        }
        .padding(.vertical, 2)
    }
}
