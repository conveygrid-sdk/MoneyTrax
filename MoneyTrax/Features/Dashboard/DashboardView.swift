import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var profiles: [UserProfile]
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @Query(sort: \Income.date, order: .reverse) private var allIncomes: [Income]

    private var profile: UserProfile? { profiles.first }
    private var currency: String { profile?.currencySymbol ?? "₹" }

    private var isGuest: Bool { profiles.isEmpty }
    private var totalTransactions: Int { allExpenses.count + allIncomes.count }
    private var isLimitReached: Bool { isGuest && totalTransactions >= AppState.guestTransactionLimit }

    private var currentMonth: Int { Date().monthNumber }
    private var currentYear: Int { Date().yearNumber }

    private var monthlyExpenses: Double {
        allExpenses
            .filter { $0.date.monthNumber == currentMonth && $0.date.yearNumber == currentYear }
            .reduce(0) { $0 + $1.amount }
    }

    private var monthlyIncome: Double {
        allIncomes
            .filter { $0.date.monthNumber == currentMonth && $0.date.yearNumber == currentYear }
            .reduce(0) { $0 + $1.amount }
    }

    private var totalBalance: Double { monthlyIncome - monthlyExpenses }

    private var recentTransactions: [(id: UUID, title: String, amount: Double, icon: String, date: Date, isIncome: Bool)] {
        let expenses: [(id: UUID, title: String, amount: Double, icon: String, date: Date, isIncome: Bool)] =
            allExpenses.prefix(10).map { (id: $0.id, title: $0.category, amount: $0.amount, icon: $0.categoryIcon, date: $0.date, isIncome: false) }

        let incomes: [(id: UUID, title: String, amount: Double, icon: String, date: Date, isIncome: Bool)] =
            allIncomes.prefix(10).map { (id: $0.id, title: $0.source, amount: $0.amount, icon: "arrow.down.circle.fill", date: $0.date, isIncome: true) }

        return (expenses + incomes)
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting header
                    greetingSection

                    // Guest Trial Banner
                    if isGuest {
                        guestTrialBanner
                    }

                    // Balance card
                    balanceCard

                    // Income / Expense summary
                    HStack(spacing: 12) {
                        summaryCard(
                            title: "Income",
                            amount: monthlyIncome,
                            icon: "arrow.down.left.circle.fill",
                            color: .incomeGreen,
                            gradient: Color.incomeGradient
                        )
                        summaryCard(
                            title: "Expenses",
                            amount: monthlyExpenses,
                            icon: "arrow.up.right.circle.fill",
                            color: .expenseRed,
                            gradient: Color.expenseGradient
                        )
                    }

                    // Quick actions
                    quickActionsSection

                    // Recent transactions
                    recentTransactionsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.elevatedBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Sections

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().greeting + ",")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(profile?.firstName ?? "Guest")
                .font(.title.weight(.bold))

            Text(Date().monthYearString)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var guestTrialBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: isLimitReached ? "exclamationmark.circle.fill" : "sparkles")
                .font(.title3)
                .foregroundStyle(isLimitReached ? Color.expenseRed : Color(red: 0.18, green: 0.34, blue: 0.96))

            VStack(alignment: .leading, spacing: 2) {
                Text(isLimitReached ? "Guest Limit Reached (\(totalTransactions)/\(AppState.guestTransactionLimit))" : "Guest Mode (\(totalTransactions)/\(AppState.guestTransactionLimit) used)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(isLimitReached ? "Create your profile to continue adding transactions" : "Try MoneyTrax with up to 3 transactions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Create Profile") {
                appState.showCreateProfileSheet = true
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(red: 0.18, green: 0.34, blue: 0.96))
            .clipShape(Capsule())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isLimitReached ? Color.expenseRed.opacity(0.1) : Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isLimitReached ? Color.expenseRed.opacity(0.3) : Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.2), lineWidth: 1)
        )
    }

    private var balanceCard: some View {
        VStack(spacing: 14) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Text(totalBalance.currencyFormatted(symbol: currency))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            Text("this month")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(red: 0.18, green: 0.34, blue: 0.96).opacity(0.35), radius: 16, y: 8)
    }

    private func summaryCard(title: String, amount: Double, icon: String, color: Color, gradient: LinearGradient) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(amount.currencyFormatted(symbol: currency))
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            Button {
                if isLimitReached {
                    appState.showCreateProfileSheet = true
                } else {
                    appState.showAddExpenseSheet = true
                }
            } label: {
                Label("Add Expense", systemImage: "minus.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.expenseRed)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityIdentifier("quickAddExpense")

            Button {
                if isLimitReached {
                    appState.showCreateProfileSheet = true
                } else {
                    appState.showAddIncomeSheet = true
                }
            } label: {
                Label("Add Income", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.incomeGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .accessibilityIdentifier("quickAddIncome")
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                Button {
                    appState.selectedTab = .transactions
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                }
            }

            if recentTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Tap the buttons above to add your first expense or income")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    ForEach(recentTransactions, id: \.id) { tx in
                        HStack(spacing: 14) {
                            Image(systemName: tx.icon)
                                .font(.title3)
                                .foregroundStyle(tx.isIncome ? Color.incomeGreen : Color.expenseRed)
                                .frame(width: 40, height: 40)
                                .background(
                                    (tx.isIncome ? Color.incomeGreen : Color.expenseRed).opacity(0.12)
                                )
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tx.title)
                                    .font(.subheadline.weight(.medium))
                                Text(tx.date.relativeDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(tx.isIncome ? "+" : "-")\(tx.amount.currencyFormatted(symbol: currency))")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(tx.isIncome ? Color.incomeGreen : Color.expenseRed)
                        }
                        .padding(.vertical, 10)

                        if tx.id != recentTransactions.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(16)
                .cardStyle()
            }
        }
    }
}
