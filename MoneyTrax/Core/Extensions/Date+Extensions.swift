import Foundation

extension Date {
    /// Returns greeting based on time of day
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }

    /// Formatted as "September 2026"
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    /// Formatted as "21 Sep"
    var shortDayMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self)
    }

    /// Formatted as "Sep 21, 2026"
    var mediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Formatted as "21 Sep, 2:30 PM"
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, h:mm a"
        return formatter.string(from: self)
    }

    /// Start of current month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// End of current month
    var endOfMonth: Date {
        let calendar = Calendar.current
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { return self }
        return calendar.date(byAdding: .second, value: -1, to: nextMonth) ?? self
    }

    /// Start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Check if same month and year
    func isSameMonthAs(_ other: Date) -> Bool {
        let cal = Calendar.current
        return cal.component(.month, from: self) == cal.component(.month, from: other) &&
               cal.component(.year, from: self) == cal.component(.year, from: other)
    }

    /// Month number (1-12)
    var monthNumber: Int {
        Calendar.current.component(.month, from: self)
    }

    /// Year number
    var yearNumber: Int {
        Calendar.current.component(.year, from: self)
    }

    /// Day of month string
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }

    /// Relative description like "Today", "Yesterday", or date
    var relativeDescription: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return mediumDateString
        }
    }
}
