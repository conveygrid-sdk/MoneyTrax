import XCTest
@testable import MoneyTrax

final class DateExtensionsTests: XCTestCase {

    func testGreeting() {
        let now = Date()
        let greeting = now.greeting
        XCTAssertTrue([
            "Good Morning",
            "Good Afternoon",
            "Good Evening",
            "Good Night"
        ].contains(greeting))
    }

    func testRelativeDescriptionToday() {
        let today = Date()
        XCTAssertEqual(today.relativeDescription, "Today")
    }

    func testRelativeDescriptionYesterday() {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            XCTFail("Failed to create yesterday's date")
            return
        }
        XCTAssertEqual(yesterday.relativeDescription, "Yesterday")
    }

    func testStartAndEndOfMonth() {
        let date = Date()
        let start = date.startOfMonth
        let end = date.endOfMonth

        let cal = Calendar.current
        XCTAssertEqual(cal.component(.day, from: start), 1)
        XCTAssertTrue(end > start)
        XCTAssertEqual(cal.component(.month, from: start), cal.component(.month, from: date))
    }

    func testIsSameMonthAs() {
        let date1 = Date()
        let date2 = date1.startOfMonth
        XCTAssertTrue(date1.isSameMonthAs(date2))

        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: date1) else {
            XCTFail("Failed to get next month")
            return
        }
        XCTAssertFalse(date1.isSameMonthAs(nextMonth))
    }
}
