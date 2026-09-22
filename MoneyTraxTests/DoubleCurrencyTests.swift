import XCTest
@testable import MoneyTrax

final class DoubleCurrencyTests: XCTestCase {

    func testCurrencyFormattedDefaultINR() {
        let amount: Double = 1500
        let formatted = amount.currencyFormatted()
        XCTAssertTrue(formatted.contains("₹"))
        XCTAssertTrue(formatted.contains("1,500"))
    }

    func testCurrencyFormattedCustomSymbol() {
        let amount: Double = 2500.50
        let formatted = amount.currencyFormatted(symbol: "$")
        XCTAssertTrue(formatted.hasPrefix("$"))
        XCTAssertTrue(formatted.contains("2,500.5"))
    }

    func testCurrencyFormattedNegative() {
        let amount: Double = -750
        let formatted = amount.currencyFormatted(symbol: "₹")
        XCTAssertTrue(formatted.hasPrefix("-₹"))
        XCTAssertTrue(formatted.contains("750"))
    }

    func testCurrencyFormattedZero() {
        let amount: Double = 0
        let formatted = amount.currencyFormatted(symbol: "₹")
        XCTAssertEqual(formatted, "₹0")
    }

    func testCompactFormatted() {
        XCTAssertEqual((500.0).compactFormatted, "500")
        XCTAssertEqual((1500.0).compactFormatted, "1.5K")
        XCTAssertEqual((250_000.0).compactFormatted, "2.5L")
        XCTAssertEqual((20_000_000.0).compactFormatted, "2.0Cr")
    }
}
