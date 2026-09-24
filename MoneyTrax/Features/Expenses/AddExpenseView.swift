import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Query private var categories: [ExpenseCategory]
    @Query private var profiles: [UserProfile]
    @Query private var allExpenses: [Expense]
    @Query private var allIncomes: [Income]

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }
    private var isGuest: Bool { profiles.isEmpty }
    private var totalTransactions: Int { allExpenses.count + allIncomes.count }
    private var isLimitReached: Bool { isGuest && !isEditing && totalTransactions >= AppState.guestTransactionLimit }

    // Edit mode
    var existingExpense: Expense?

    @State private var amountText = ""
    @State private var selectedCategory = ""
    @State private var selectedCategoryIcon = "tag.fill"
    @State private var date = Date()
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var note = ""
    @State private var showCategoryPicker = false

    private var isEditing: Bool { existingExpense != nil }

    private var isValid: Bool {
        if isLimitReached { return false }
        guard let amount = Double(amountText), amount > 0 else { return false }
        return !selectedCategory.isEmpty
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
                            .accessibilityIdentifier("expenseAmountField")
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Amount")
                }

                // Category
                Section {
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            Image(systemName: selectedCategoryIcon)
                                .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                            Text(selectedCategory.isEmpty ? "Select Category" : selectedCategory)
                                .foregroundStyle(selectedCategory.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .accessibilityIdentifier("categorySelector")
                } header: {
                    Text("Category")
                }

                // Details
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("expenseDatePicker")

                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases) { method in
                            Label(method.rawValue, systemImage: method.icon)
                                .tag(method)
                        }
                    }
                    .accessibilityIdentifier("paymentMethodPicker")
                } header: {
                    Text("Details")
                }

                // Notes
                Section {
                    TextField("Add a note (optional)", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                        .accessibilityIdentifier("expenseNoteField")
                } header: {
                    Text("Note")
                }
            }
            .navigationTitle(isEditing ? "Edit Expense" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        hideKeyboard()
                        saveExpense()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("saveExpenseButton")
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
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    selectedCategory: $selectedCategory,
                    selectedIcon: $selectedCategoryIcon
                )
            }
            .onAppear {
                if let expense = existingExpense {
                    amountText = String(format: "%.0f", expense.amount)
                    selectedCategory = expense.category
                    selectedCategoryIcon = expense.categoryIcon
                    date = expense.date
                    paymentMethod = PaymentMethod(rawValue: expense.paymentMethod) ?? .cash
                    note = expense.note
                }
            }
        }
    }

    private func saveExpense() {
        if isLimitReached {
            dismiss()
            appState.showCreateProfileSheet = true
            return
        }
        guard let amount = Double(amountText), amount > 0 else { return }

        if let expense = existingExpense {
            expense.amount = amount
            expense.category = selectedCategory
            expense.categoryIcon = selectedCategoryIcon
            expense.date = date
            expense.paymentMethod = paymentMethod.rawValue
            expense.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            expense.updatedAt = Date()
        } else {
            let expense = Expense(
                amount: amount,
                category: selectedCategory,
                categoryIcon: selectedCategoryIcon,
                date: date,
                paymentMethod: paymentMethod.rawValue,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            modelContext.insert(expense)
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Category Picker

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [ExpenseCategory]
    @Binding var selectedCategory: String
    @Binding var selectedIcon: String

    var body: some View {
        NavigationStack {
            List(categories) { category in
                Button {
                    selectedCategory = category.name
                    selectedIcon = category.icon
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: category.icon)
                            .font(.title3)
                            .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                            .frame(width: 36)

                        Text(category.name)
                            .foregroundStyle(.primary)

                        Spacer()

                        if selectedCategory == category.name {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
