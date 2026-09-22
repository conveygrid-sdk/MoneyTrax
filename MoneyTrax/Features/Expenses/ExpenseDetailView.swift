import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    let expense: Expense

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    private var currency: String { profiles.first?.currencySymbol ?? "₹" }

    var body: some View {
        List {
            // Amount header
            Section {
                VStack(spacing: 8) {
                    Image(systemName: expense.categoryIcon)
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.expenseRed)
                        .clipShape(Circle())

                    Text(expense.amount.currencyFormatted(symbol: currency))
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text(expense.category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            // Details
            Section("Details") {
                LabeledContent("Category") {
                    Label(expense.category, systemImage: expense.categoryIcon)
                }
                LabeledContent("Date") {
                    Text(expense.date.mediumDateString)
                }
                LabeledContent("Payment Method") {
                    let pm = PaymentMethod(rawValue: expense.paymentMethod) ?? .other
                    Label(pm.rawValue, systemImage: pm.icon)
                }
                if !expense.note.isEmpty {
                    LabeledContent("Note") {
                        Text(expense.note)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Metadata
            Section("Info") {
                LabeledContent("Created") {
                    Text(expense.createdAt.dateTimeString)
                        .foregroundStyle(.secondary)
                }
                if expense.updatedAt != expense.createdAt {
                    LabeledContent("Updated") {
                        Text(expense.updatedAt.dateTimeString)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Actions
            Section {
                Button {
                    showEditSheet = true
                } label: {
                    Label("Edit Expense", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Expense", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            AddExpenseView(existingExpense: expense)
        }
        .confirmationDialog(
            "Delete Expense",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(expense)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("This expense of \(expense.amount.currencyFormatted(symbol: currency)) will be permanently deleted.")
        }
    }
}
