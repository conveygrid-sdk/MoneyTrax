import XCTest
@testable import MoneyTrax

final class ValidatorsTests: XCTestCase {

    // MARK: - Email Validation Tests

    func testValidEmails() {
        XCTAssertTrue(Validators.isValidEmail("user@example.com"))
        XCTAssertTrue(Validators.isValidEmail("first.last@company.co.in"))
        XCTAssertTrue(Validators.isValidEmail("test+tag@domain.org"))
        XCTAssertTrue(Validators.isValidEmail("name123@sub.domain.com"))
    }

    func testInvalidEmails() {
        XCTAssertFalse(Validators.isValidEmail(""))
        XCTAssertFalse(Validators.isValidEmail("   "))
        XCTAssertFalse(Validators.isValidEmail("plainaddress"))
        XCTAssertFalse(Validators.isValidEmail("@missingusername.com"))
        XCTAssertFalse(Validators.isValidEmail("username@.com"))
        XCTAssertFalse(Validators.isValidEmail("username@domain"))
        XCTAssertFalse(Validators.isValidEmail("username@domain..com"))
    }

    // MARK: - Mobile Validation Tests

    func testValidMobiles() {
        XCTAssertTrue(Validators.isValidMobile("9876543210"))
        XCTAssertTrue(Validators.isValidMobile("+919876543210"))
        XCTAssertTrue(Validators.isValidMobile("987-654-3210"))
        XCTAssertTrue(Validators.isValidMobile("(987) 654-3210"))
        XCTAssertTrue(Validators.isValidMobile("012345678901")) // 12 digits
    }

    func testInvalidMobiles() {
        XCTAssertFalse(Validators.isValidMobile(""))
        XCTAssertFalse(Validators.isValidMobile("12345")) // too short
        XCTAssertFalse(Validators.isValidMobile("123456789")) // 9 digits
        XCTAssertFalse(Validators.isValidMobile("abcdefghij")) // no digits
        XCTAssertFalse(Validators.isValidMobile("1234567890123456")) // > 15 digits
    }

    // MARK: - Name Validation Tests

    func testValidNames() {
        XCTAssertTrue(Validators.isValidName("John"))
        XCTAssertTrue(Validators.isValidName("Al"))
        XCTAssertTrue(Validators.isValidName("Mary Jane"))
        XCTAssertTrue(Validators.isValidName("  Harshil  "))
    }

    func testInvalidNames() {
        XCTAssertFalse(Validators.isValidName(""))
        XCTAssertFalse(Validators.isValidName(" "))
        XCTAssertFalse(Validators.isValidName("A"))
    }

    // MARK: - Amount Validation Tests

    func testValidAmounts() {
        XCTAssertTrue(Validators.isValidAmount(0.01))
        XCTAssertTrue(Validators.isValidAmount(100.0))
        XCTAssertTrue(Validators.isValidAmount(99_999_999.99))
        XCTAssertTrue(Validators.isValidAmountString("500"))
        XCTAssertTrue(Validators.isValidAmountString("1234.56"))
    }

    func testInvalidAmounts() {
        XCTAssertFalse(Validators.isValidAmount(0.0))
        XCTAssertFalse(Validators.isValidAmount(-10.0))
        XCTAssertFalse(Validators.isValidAmount(100_000_000.0))
        XCTAssertFalse(Validators.isValidAmountString("0"))
        XCTAssertFalse(Validators.isValidAmountString("-50"))
        XCTAssertFalse(Validators.isValidAmountString("abc"))
        XCTAssertFalse(Validators.isValidAmountString(""))
    }
}
