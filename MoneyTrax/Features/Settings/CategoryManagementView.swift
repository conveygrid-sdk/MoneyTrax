import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = "tag.fill"
    @State private var showIconPicker = false

    private var defaultCategories: [ExpenseCategory] {
        categories.filter(\.isDefault)
    }

    private var customCategories: [ExpenseCategory] {
        categories.filter { !$0.isDefault }
    }

    private let availableIcons = [
        "tag.fill", "star.fill", "heart.fill", "gift.fill",
        "car.fill", "bus.fill", "tram.fill", "bicycle",
        "house.fill", "building.2.fill", "tent.fill",
        "cup.and.saucer.fill", "mug.fill", "wineglass.fill",
        "gamecontroller.fill", "headphones", "music.note",
        "book.fill", "pencil", "globe.americas.fill",
        "pawprint.fill", "leaf.fill", "drop.fill",
        "wrench.fill", "hammer.fill", "paintbrush.fill",
        "scissors", "bandage.fill", "pills.fill",
        "phone.fill", "desktopcomputer", "tv.fill",
        "sportscourt.fill", "figure.run", "dumbbell.fill",
    ]

    var body: some View {
        List {
            // Default categories
            Section("Default Categories") {
                ForEach(defaultCategories) { category in
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.body)
                            .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                            .frame(width: 28)
                        Text(category.name)
                    }
                }
            }

            // Custom categories
            Section {
                ForEach(customCategories) { category in
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.body)
                            .foregroundStyle(Color.budgetOrange)
                            .frame(width: 28)
                        Text(category.name)
                        Spacer()
                        Text("Custom")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.elevatedBackground)
                            .clipShape(Capsule())
                    }
                }
                .onDelete(perform: deleteCustomCategory)
            } header: {
                Text("Custom Categories")
            } footer: {
                if customCategories.isEmpty {
                    Text("No custom categories yet. Tap + to add one.")
                }
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(red: 0.18, green: 0.34, blue: 0.96))
                }
            }
        }
        .alert("New Category", isPresented: $showAddCategory) {
            TextField("Category name", text: $newCategoryName)
            Button("Add") {
                addCategory()
            }
            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {
                newCategoryName = ""
            }
        } message: {
            Text("Enter a name for the new expense category")
        }
    }

    private func addCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let repo = CategoryRepository(modelContext: modelContext)
        guard !repo.exists(name: name) else {
            newCategoryName = ""
            return
        }

        let category = ExpenseCategory(name: name, icon: "tag.fill", isDefault: false)
        modelContext.insert(category)
        try? modelContext.save()
        newCategoryName = ""
    }

    private func deleteCustomCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = customCategories[index]
            modelContext.delete(category)
        }
        try? modelContext.save()
    }
}
