import Foundation

enum TimeScope: String, CaseIterable, Identifiable {
    case all
    case today
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部时间"
        case .today: return "只看今天"
        case .custom: return "自定义区间"
        }
    }
}

@Observable
final class RecordsViewModel {
    var type: OperateType = .all
    var timeScope: TimeScope = .all
    var ascending = false
    var customStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    var customEnd = Date()

    func apply(to records: [OperationRecord]) -> [OperationRecord] {
        var result = records

        if type != .all {
            result = result.filter { $0.operateType == type.rawValue }
        }

        switch timeScope {
        case .all:
            break
        case .today:
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: Date())
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? Date()
            result = result.filter { $0.date >= start && $0.date < end }
        case .custom:
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: customStart)
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: customEnd)) ?? customEnd
            result = result.filter { $0.date >= start && $0.date < end }
        }

        return result.sorted { ascending ? $0.date < $1.date : $0.date > $1.date }
    }

    // MARK: - updata 记录的新旧数据解码

    static func decodeDict(_ json: String?) -> [String: Any]? {
        guard let json,
              let data = json.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict
    }

    static func name(of record: OperationRecord) -> String {
        if record.operateType == "updata",
           let old = decodeDict(record.oldDataJSON),
           let name = old["name"] as? String {
            return name
        }
        return record.name ?? "未知商品"
    }

    static func spec(of record: OperationRecord) -> String {
        if record.operateType == "updata",
           let old = decodeDict(record.oldDataJSON),
           let spec = old["spec"] as? String {
            return spec
        }
        return record.spec ?? ""
    }
}
