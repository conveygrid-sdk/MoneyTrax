import SwiftUI
import SwiftData

struct AddIncomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Query private var profiles: [UserProfile]
    @Query private var allExpenses: [Expense]
    @Query private var allIncomes: [Income]

    var existingIncome: Income?

    @State private var amountText = ""
    @State private var source = ""
    @State private var date = Date()
    @State private var note = ""
    @State private var showSourcePicker = false

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }
    private var isEditing: Bool { existingIncome != nil }
    private var isGuest: Bool { profiles.isEmpty }
    private var totalTransactions: Int { allExpenses.count + allIncomes.count }
    private var isLimitReached: Bool { isGuest && !isEditing && totalTransactions >= AppState.guestTransactionLimit }

    private var isValid: Bool {
        if isLimitReached { return false }
        guard let amount = Double(amountText), amount > 0 else { return false }
        return !source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                if isLimitReached {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color.expenseRed)
                                Text("Transaction Limit Reached")
                                    .font(.subheadline.weight(.semibold))
                            }
                            Text("Guest mode allows up to 3 transactions. Please create your profile to add more.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button("Create Profile Now") {
                                dismiss()
                                appState.showCreateProfileSheet = true
                            }
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Amount
                Section {
                    HStack {
                        Text(currency)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("0", text: $amountText)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .accessibilityIdentifier("incomeAmountField")
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Amount")
                }

                // Source
                Section {
                    TextField("e.g. Salary, Freelance", text: $source)
                        .accessibilityIdentifier("incomeSourceField")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AppConstants.defaultIncomeSources, id: \.self) { src in
                                Button {
                                    source = src
                                } label: {
                                    Text(src)
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(source == src ? Color.incomeGreen : Color.elevatedBackground)
                                        .foregroundStyle(source == src ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                } header: {
                    Text("Source")
                }

                // Date
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("incomeDatePicker")
                } header: {
                    Text("Date")
                }

                // Notes
                Section {
                    TextField("Add a note (optional)", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                        .accessibilityIdentifier("incomeNoteField")
                } header: {
                    Text("Note")
                }
            }
            .navigationTitle(isEditing ? "Edit Income" : "Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        hideKeyboard()
                        saveIncome()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("saveIncomeButton")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                }
            }
            .onAppear {
                if let income = existingIncome {
                    amountText = String(format: "%.0f", income.amount)
                    source = income.source
                    date = income.date
                    note = income.note
                }
            }
        }
    }

    private func saveIncome() {
        if isLimitReached {
            dismiss()
            appState.showCreateProfileSheet = true
            return
        }
        guard let amount = Double(amountText), amount > 0 else { return }

        if let income = existingIncome {
            income.amount = amount
            income.source = source.trimmingCharacters(in: .whitespacesAndNewlines)
            income.date = date
            income.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            income.updatedAt = Date()
        } else {
            let income = Income(
                amount: amount,
                source: source.trimmingCharacters(in: .whitespacesAndNewlines),
                date: date,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            modelContext.insert(income)
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Income List View

struct IncomeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]
    @Query private var profiles: [UserProfile]

    @State private var searchText = ""

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    private var filteredIncomes: [Income] {
        if searchText.isEmpty { return incomes }
        return incomes.filter {
            $0.source.localizedCaseInsensitiveContains(searchText) ||
            $0.note.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if incomes.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 56))
                        .foregroundStyle(.tertiary)
                    Text("No Income Yet")
                        .font(.title3.weight(.semibold))
                    Text("Tap + to add your first income entry")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(40)
            } else {
                List {
                    ForEach(filteredIncomes) { income in
                        NavigationLink {
                            IncomeDetailView(income: income)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .frame(width: 38, height: 38)
                                    .background(Color.incomeGreen)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(income.source)
                                        .font(.subheadline.weight(.medium))
                                    Text(income.date.shortDayMonth)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("+\(income.amount.currencyFormatted(symbol: currency))")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.incomeGreen)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteIncomes)
                }
                .searchable(text: $searchText, prompt: "Search income")
            }
        }
    }

    private func deleteIncomes(at offsets: IndexSet) {
        for index in offsets {
            let income = filteredIncomes[index]
            modelContext.delete(income)
        }
        try? modelContext.save()
    }
}

// MARK: - Income Detail View

struct IncomeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    let income: Income

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.incomeGreen)
                        .clipShape(Circle())

                    Text("+\(income.amount.currencyFormatted(symbol: currency))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.incomeGreen)

                    Text(income.source)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section("Details") {
                LabeledContent("Source", value: income.source)
                LabeledContent("Date", value: income.date.mediumDateString)
                if !income.note.isEmpty {
                    LabeledContent("Note") {
                        Text(income.note)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button { showEditSheet = true } label: {
                    Label("Edit Income", systemImage: "pencil")
                }
                Button(role: .destructive) { showDeleteConfirmation = true } label: {
                    Label("Delete Income", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Income Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            AddIncomeView(existingIncome: income)
        }
        .confirmationDialog("Delete Income", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(income)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("This income entry will be permanently deleted.")
        }
    }
}
