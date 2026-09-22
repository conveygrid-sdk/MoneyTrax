import Foundation

extension Double {
    /// Format as currency with the given symbol (e.g. "₹42,500", "-₹500")
    func currencyFormatted(symbol: String = "₹") -> String {
        let isNegative = self < 0
        let absValue = abs(self)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3

        // Use Indian grouping for INR
        if symbol == "₹" {
            formatter.groupingSize = 3
            formatter.secondaryGroupingSize = 2
        }

        let formatted = formatter.string(from: NSNumber(value: absValue)) ?? String(format: "%.2f", absValue)
        return isNegative ? "-\(symbol)\(formatted)" : "\(symbol)\(formatted)"
    }

    /// Compact format for large numbers (e.g. "42.5K")
    var compactFormatted: String {
        if self >= 10_000_000 {
            return String(format: "%.1fCr", self / 10_000_000)
        } else if self >= 100_000 {
            return String(format: "%.1fL", self / 100_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", self / 1_000)
        }
        return String(format: "%.0f", self)
    }
}
