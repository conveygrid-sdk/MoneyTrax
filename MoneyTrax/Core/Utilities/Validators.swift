import Foundation

enum Validators {
    // MARK: - Email Validation

    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let pattern = #"^[A-Za-z0-9._%+-]+@([A-Za-z0-9]+(-[A-Za-z0-9]+)*\.)+[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - Mobile Validation

    static func isValidMobile(_ mobile: String) -> Bool {
        let digits = mobile.filter(\.isNumber)
        return digits.count >= 10 && digits.count <= 15
    }

    // MARK: - Name Validation

    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count >= 2
    }

    // MARK: - Amount Validation

    static func isValidAmount(_ amount: Double) -> Bool {
        amount > 0 && amount < 100_000_000
    }

    static func isValidAmountString(_ text: String) -> Bool {
        guard let amount = Double(text) else { return false }
        return isValidAmount(amount)
    }
}
