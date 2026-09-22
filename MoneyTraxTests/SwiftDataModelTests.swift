import XCTest
import SwiftData
@testable import MoneyTrax

@MainActor
final class SwiftDataModelTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([
            UserProfile.self,
            Expense.self,
            Income.self,
            ExpenseCategory.self,
            Budget.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - UserProfile Tests

    func testCreateAndFetchProfile() throws {
        let repo = UserProfileRepository(modelContext: context)
        let profile = UserProfile(
            firstName: "Harshil",
            email: "harshil@example.com",
            mobileNumber: "9876543210"
        )
        try repo.save(profile)

        let fetched = repo.fetch()
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.firstName, "Harshil")
        XCTAssertEqual(fetched?.email, "harshil@example.com")
        XCTAssertEqual(fetched?.currencySymbol, "₹")
    }

    func testUpdateProfile() throws {
        let repo = UserProfileRepository(modelContext: context)
        let profile = UserProfile(
            firstName: "Alice",
            email: "alice@example.com",
            mobileNumber: "9876543210"
        )
        try repo.save(profile)

        try repo.update(profile, firstName: "Alice Smith", email: "alice.smith@example.com", mobileNumber: "9876543211", currencySymbol: "$")

        let fetched = repo.fetch()
        XCTAssertEqual(fetched?.firstName, "Alice Smith")
        XCTAssertEqual(fetched?.email, "alice.smith@example.com")
        XCTAssertEqual(fetched?.currencySymbol, "$")
    }

    func testProfileWithFullName() throws {
        let repo = UserProfileRepository(modelContext: context)
        let profile = UserProfile(
            fullName: "Harshil Patel",
            email: "harshil.patel@example.com",
            mobileNumber: "9876543210"
        )
        try repo.save(profile)

        let fetched = repo.fetch()
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.fullName, "Harshil Patel")
        XCTAssertEqual(fetched?.firstName, "Harshil Patel")

        try repo.update(profile, fullName: "Harshil Kumar Patel", email: "harshil.kumar@example.com", mobileNumber: "9876543210")
        XCTAssertEqual(repo.fetch()?.fullName, "Harshil Kumar Patel")
    }

    func testConsentIntegrationProtocolWithFullName() async throws {
        final class MockConsentManager: ConsentIntegrationProtocol {
            var configured = false
            var capturedFullName: String?
            var capturedEmail: String?
            var capturedMobile: String?

            func configure() {
                configured = true
            }

            func captureConsent(fullName: String, email: String, mobile: String) async throws {
                capturedFullName = fullName
                capturedEmail = email
                capturedMobile = mobile
            }
        }

        let mock = MockConsentManager()
        mock.configure()
        XCTAssertTrue(mock.configured)

        try await mock.captureConsent(fullName: "Harshil Patel", email: "harshil@example.com", mobile: "9876543210")
        XCTAssertEqual(mock.capturedFullName, "Harshil Patel")
        XCTAssertEqual(mock.capturedEmail, "harshil@example.com")
        XCTAssertEqual(mock.capturedMobile, "9876543210")

        // Test backward-compatibility forwarder
        try await mock.captureConsent(firstName: "Harshil Forward", email: "forward@example.com", mobile: "9123456789")
        XCTAssertEqual(mock.capturedFullName, "Harshil Forward")
        XCTAssertEqual(mock.capturedEmail, "forward@example.com")
        XCTAssertEqual(mock.capturedMobile, "9123456789")
    }

    func testCreateProfileConsentDismissalResetsLoadingAndDoesNotCreateProfile() async throws {
        final class CancelledConsentManager: ConsentIntegrationProtocol {
            func configure() {}
            func captureConsent(fullName: String, email: String, mobile: String) async throws {
                throw ConsentError.cancelled
            }
        }

        let vm = CreateProfileViewModel(consentManager: CancelledConsentManager())
        vm.fullName = "Harshil Bhatt"
        vm.email = "harshil.bhatt@rysun.com"
        vm.mobileNumber = "8460217396"

        XCTAssertTrue(vm.isFormValid)
        vm.createProfile(modelContext: context)

        // Yield to allow Task @MainActor to execute
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(vm.isLoading, "Button spinner must stop when sheet is dismissed")
        XCTAssertFalse(vm.showError, "Dismissal should not show an error alert")
        XCTAssertNil(UserProfileRepository(modelContext: context).fetch(), "Profile must NOT be saved if dismissed")
    }

    func testCreateProfileConsentErrorShowsAlertAndDoesNotCreateProfile() async throws {
        struct MockError: LocalizedError {
            var errorDescription: String? { "Invalid application key: Invalid application key" }
        }
        final class ErrorConsentManager: ConsentIntegrationProtocol {
            func configure() {}
            func captureConsent(fullName: String, email: String, mobile: String) async throws {
                throw MockError()
            }
        }

        let vm = CreateProfileViewModel(consentManager: ErrorConsentManager())
        vm.fullName = "Harshil Bhatt"
        vm.email = "harshil.bhatt@rysun.com"
        vm.mobileNumber = "8460217396"

        XCTAssertTrue(vm.isFormValid)
        vm.createProfile(modelContext: context)

        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(vm.isLoading, "Button spinner must stop on error")
        XCTAssertTrue(vm.showError, "Should show error alert")
        XCTAssertEqual(vm.errorMessage, "Invalid application key: Invalid application key")
        XCTAssertNil(UserProfileRepository(modelContext: context).fetch(), "Profile must NOT be saved on error")
    }

    func testCreateProfileConsentSuccessCreatesProfile() async throws {
        final class SuccessConsentManager: ConsentIntegrationProtocol {
            func configure() {}
            func captureConsent(fullName: String, email: String, mobile: String) async throws {}
        }

        let vm = CreateProfileViewModel(consentManager: SuccessConsentManager())
        vm.fullName = "Harshil Bhatt"
        vm.email = "harshil.bhatt@rysun.com"
        vm.mobileNumber = "8460217396"

        XCTAssertTrue(vm.isFormValid)
        vm.createProfile(modelContext: context)

        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(vm.isLoading)
        XCTAssertFalse(vm.showError)
        let profile = UserProfileRepository(modelContext: context).fetch()
        XCTAssertNotNil(profile, "Profile must be saved on consent success")
        XCTAssertEqual(profile?.fullName, "Harshil Bhatt")
        XCTAssertEqual(profile?.email, "harshil.bhatt@rysun.com")
        XCTAssertEqual(profile?.mobileNumber, "8460217396")
    }

    // MARK: - Expense Tests

    func testCreateAndFetchExpenses() throws {
        let repo = ExpenseRepository(modelContext: context)
        let expense = Expense(
            amount: 250.0,
            category: "Food",
            categoryIcon: "fork.knife",
            paymentMethod: "UPI",
            note: "Lunch"
        )
        try repo.save(expense)

        let all = repo.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.amount, 250.0)
        XCTAssertEqual(all.first?.category, "Food")
    }

    func testDeleteExpense() throws {
        let repo = ExpenseRepository(modelContext: context)
        let expense = Expense(amount: 100.0, category: "Transport")
        try repo.save(expense)
        XCTAssertEqual(repo.fetchAll().count, 1)

        try repo.delete(expense)
        XCTAssertEqual(repo.fetchAll().count, 0)
    }

    // MARK: - Income Tests

    func testCreateAndFetchIncome() throws {
        let repo = IncomeRepository(modelContext: context)
        let income = Income(amount: 50000.0, source: "Salary", note: "Monthly pay")
        try repo.save(income)

        let all = repo.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.amount, 50000.0)
        XCTAssertEqual(all.first?.source, "Salary")
    }

    // MARK: - Category Tests

    func testCategoryDefaultsAndCustom() throws {
        let repo = CategoryRepository(modelContext: context)
        let defaultCat = ExpenseCategory(name: "Food", icon: "fork.knife", isDefault: true)
        let customCat = ExpenseCategory(name: "Gadgets", icon: "laptopcomputer", isDefault: false)

        try repo.save(defaultCat)
        try repo.save(customCat)

        let all = repo.fetchAll()
        XCTAssertEqual(all.count, 2)
        // Defaults should sort before custom
        XCTAssertEqual(all.first?.name, "Food")
        XCTAssertTrue(all.first?.isDefault == true)

        let defaults = repo.fetchDefaults()
        XCTAssertEqual(defaults.count, 1)

        let custom = repo.fetchCustom()
        XCTAssertEqual(custom.count, 1)
        XCTAssertEqual(custom.first?.name, "Gadgets")

        XCTAssertTrue(repo.exists(name: "Food"))
        XCTAssertFalse(repo.exists(name: "Nonexistent"))
    }

    // MARK: - Budget Tests

    func testBudgetUpsertAndFetch() throws {
        let repo = BudgetRepository(modelContext: context)
        try repo.upsert(month: 9, year: 2026, amount: 30000.0, category: nil)

        let overall = repo.overallBudget(month: 9, year: 2026)
        XCTAssertNotNil(overall)
        XCTAssertEqual(overall?.amount, 30000.0)

        // Upsert update existing
        try repo.upsert(month: 9, year: 2026, amount: 35000.0, category: nil)
        let updated = repo.overallBudget(month: 9, year: 2026)
        XCTAssertEqual(updated?.amount, 35000.0)

        // Category budget
        try repo.upsert(month: 9, year: 2026, amount: 10000.0, category: "Food")
        let foodBudget = repo.categoryBudget(month: 9, year: 2026, category: "Food")
        XCTAssertNotNil(foodBudget)
        XCTAssertEqual(foodBudget?.amount, 10000.0)
    }

    // MARK: - Delete All Data Tests

    func testDeleteAllDataKeepsDefaultCategories() throws {
        let profileRepo = UserProfileRepository(modelContext: context)
        let expenseRepo = ExpenseRepository(modelContext: context)
        let incomeRepo = IncomeRepository(modelContext: context)
        let catRepo = CategoryRepository(modelContext: context)
        let budgetRepo = BudgetRepository(modelContext: context)

        // Insert data across all models
        let profile = UserProfile(firstName: "Test", email: "test@example.com", mobileNumber: "1234567890")
        try profileRepo.save(profile)
        try expenseRepo.save(Expense(amount: 100, category: "Food"))
        try incomeRepo.save(Income(amount: 1000, source: "Salary"))
        try catRepo.save(ExpenseCategory(name: "Food", icon: "fork.knife", isDefault: true))
        try catRepo.save(ExpenseCategory(name: "CustomCat", icon: "tag.fill", isDefault: false))
        try budgetRepo.upsert(month: 9, year: 2026, amount: 5000, category: nil)

        // Perform full deletion
        try profileRepo.deleteAllData()

        XCTAssertNil(profileRepo.fetch())
        XCTAssertEqual(expenseRepo.fetchAll().count, 0)
        XCTAssertEqual(incomeRepo.fetchAll().count, 0)
        XCTAssertNil(budgetRepo.overallBudget(month: 9, year: 2026))

        // Default category should still exist, custom category should be deleted
        let remainingCats = catRepo.fetchAll()
        XCTAssertEqual(remainingCats.count, 1)
        XCTAssertEqual(remainingCats.first?.name, "Food")
        XCTAssertTrue(remainingCats.first?.isDefault == true)
    }

}
