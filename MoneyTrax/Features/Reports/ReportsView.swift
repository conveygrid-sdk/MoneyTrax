import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]
    @Query private var profiles: [UserProfile]

    @State private var selectedMonth = Date().monthNumber
    @State private var selectedYear = Date().yearNumber

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    private var monthlyExpenses: [Expense] {
        expenses.filter {
            $0.date.monthNumber == selectedMonth && $0.date.yearNumber == selectedYear
        }
    }

    private var monthlyIncomes: [Income] {
        incomes.filter {
            $0.date.monthNumber == selectedMonth && $0.date.yearNumber == selectedYear
        }
    }

    private var totalExpense: Double { monthlyExpenses.reduce(0) { $0 + $1.amount } }
    private var totalIncome: Double { monthlyIncomes.reduce(0) { $0 + $1.amount } }
    private var savings: Double { totalIncome - totalExpense }

    // Category breakdown
    private var categoryBreakdown: [(category: String, amount: Double, color: Color)] {
        let grouped = Dictionary(grouping: monthlyExpenses) { $0.category }
        let colors: [Color] = [
            .blue, .red, .green, .orange, .purple, .pink, .teal, .indigo,
            .mint, .cyan, .brown, .yellow, .gray
        ]

        return grouped.map { (key, value) in
            let total = value.reduce(0) { $0 + $1.amount }
            let index = grouped.keys.sorted().firstIndex(of: key) ?? 0
            return (category: key, amount: total, color: colors[index % colors.count])
        }
        .sorted { $0.amount > $1.amount }
    }

    // Daily expense trend
    private var dailyTrend: [(day: Int, amount: Double)] {
        let grouped = Dictionary(grouping: monthlyExpenses) {
            Calendar.current.component(.day, from: $0.date)
        }
        return grouped.map { (day: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.day < $1.day }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Month selector
                    monthSelector

                    // Summary cards
                    summarySection

                    // Income vs Expense
                    incomeVsExpenseChart

                    // Expense by category
                    if !categoryBreakdown.isEmpty {
                        categoryChart
                    }

                    // Daily trend
                    if !dailyTrend.isEmpty {
                        dailyTrendChart
                    }

                    if expenses.isEmpty && incomes.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.elevatedBackground.ignoresSafeArea())
            .navigationTitle("Reports")
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        HStack {
            Button {
                goToPreviousMonth()
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
                goToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
            }
            .disabled(selectedMonth == Date().monthNumber && selectedYear == Date().yearNumber)
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

    // MARK: - Summary

    private var summarySection: some View {
        HStack(spacing: 10) {
            summaryItem(title: "Income", amount: totalIncome, color: .incomeGreen)
            summaryItem(title: "Expenses", amount: totalExpense, color: .expenseRed)
            summaryItem(title: "Savings", amount: savings, color: savings >= 0 ? .incomeGreen : .expenseRed)
        }
    }

    private func summaryItem(title: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount.currencyFormatted(symbol: currency))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle()
    }

    // MARK: - Income vs Expense Chart

    private var incomeVsExpenseChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expenses")
                .font(.headline)

            Chart {
                BarMark(
                    x: .value("Type", "Income"),
                    y: .value("Amount", totalIncome)
                )
                .foregroundStyle(Color.incomeGreen.gradient)
                .cornerRadius(6)

                BarMark(
                    x: .value("Type", "Expenses"),
                    y: .value("Amount", totalExpense)
                )
                .foregroundStyle(Color.expenseRed.gradient)
                .cornerRadius(6)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Category Chart

    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses by Category")
                .font(.headline)

            Chart(categoryBreakdown, id: \.category) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 220)

            // Legend
            VStack(spacing: 8) {
                ForEach(categoryBreakdown, id: \.category) { item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.category)
                            .font(.caption)
                        Spacer()
                        Text(item.amount.currencyFormatted(symbol: currency))
                            .font(.caption.weight(.medium))
                        Text(String(format: "%.0f%%", totalExpense > 0 ? (item.amount / totalExpense * 100) : 0))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Daily Trend

    private var dailyTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Expense Trend")
                .font(.headline)

            Chart(dailyTrend, id: \.day) { item in
                LineMark(
                    x: .value("Day", item.day),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(Color.expenseRed)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Day", item.day),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(Color.expenseRed.opacity(0.1).gradient)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Day", item.day),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(Color.expenseRed)
                .symbolSize(24)
            }
            .frame(height: 200)
            .chartXAxisLabel("Day of Month")
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No Data for Reports")
                .font(.headline)
            Text("Add some expenses and income to see your financial reports here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Navigation

    private func goToPreviousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
    }

    private func goToNextMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
    }
}
