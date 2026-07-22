import Foundation

enum Formatters {
    static let recordDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// 数量显示：7.0 -> "7"，201.5 -> "201.5"
    static func num(_ value: Double) -> String {
        if value == value.rounded() && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        return String(value)
    }

    static func num(_ value: Double?) -> String {
        guard let value else { return "" }
        return num(value)
    }
}
