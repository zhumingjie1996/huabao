import Foundation
import SwiftData

struct ImportReport {
    var productsAdded = 0
    var productsSkipped = 0
    var recordsAdded = 0
    var recordsSkipped = 0
    var badLines = 0

    var summary: String {
        """
        商品：新增 \(productsAdded) 条，跳过重复 \(productsSkipped) 条
        记录：新增 \(recordsAdded) 条，跳过重复 \(recordsSkipped) 条
        \(badLines > 0 ? "无法解析 \(badLines) 行" : "")
        """
    }
}

enum ImportError: LocalizedError {
    case unreadableFile

    var errorDescription: String? {
        switch self {
        case .unreadableFile: return "文件无法读取"
        }
    }
}

/// 微信云开发数据库导出文件（JSONL，每行一个 JSON 对象）导入器。
/// 自动识别集合：行内含 operateType -> operationList，否则 -> productionList。
/// 按 `_id` 去重，可重复导入。
enum CloudDataImporter {

    private static let iso8601WithFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let iso8601 = ISO8601DateFormatter()

    @discardableResult
    static func importFile(at url: URL, into context: ModelContext) throws -> ImportReport {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            throw ImportError.unreadableFile
        }

        let existingProductIDs = Set(((try? context.fetch(FetchDescriptor<Product>())) ?? []).map(\.id))
        let existingRecordIDs = Set(((try? context.fetch(FetchDescriptor<OperationRecord>())) ?? []).map(\.id))

        var report = ImportReport()

        content.enumerateLines { line, _ in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty,
                  let data = trimmed.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data),
                  let dict = obj as? [String: Any],
                  let id = dict["_id"] as? String else {
                if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                    report.badLines += 1
                }
                return
            }

            if dict["operateType"] != nil {
                if existingRecordIDs.contains(id) {
                    report.recordsSkipped += 1
                } else if let record = parseRecord(dict, id: id) {
                    context.insert(record)
                    report.recordsAdded += 1
                } else {
                    report.badLines += 1
                }
            } else {
                if existingProductIDs.contains(id) {
                    report.productsSkipped += 1
                } else if let product = parseProduct(dict, id: id) {
                    context.insert(product)
                    report.productsAdded += 1
                } else {
                    report.badLines += 1
                }
            }
        }

        try context.save()
        return report
    }

    // MARK: - 解析

    private static func parseProduct(_ dict: [String: Any], id: String) -> Product? {
        guard let name = dict["name"] as? String, !name.isEmpty else { return nil }
        let nameCode = dict["nameCode"] as? String ?? ""
        let initials = (dict["initials"] as? String) ?? String(nameCode.prefix(1)).uppercased()
        return Product(
            id: id,
            name: name,
            nameCode: nameCode,
            initials: initials,
            spec: dict["spec"] as? String ?? "",
            num: number(dict["num"]) ?? 0,
            price: stringValue(dict["price"]),
            unit: dict["unit"] as? String ?? ""
        )
    }

    private static func parseRecord(_ dict: [String: Any], id: String) -> OperationRecord? {
        guard let operateType = dict["operateType"] as? String else { return nil }
        let record = OperationRecord(
            id: id,
            productionId: dict["productionId"] as? String,
            operateType: operateType,
            operateName: dict["operateName"] as? String ?? operateType,
            date: dateValue(dict["date"]) ?? .distantPast
        )
        record.name = dict["name"] as? String
        record.spec = dict["spec"] as? String
        record.unit = dict["unit"] as? String
        record.num = number(dict["num"])
        if dict["price"] != nil {
            record.price = stringValue(dict["price"])
        }
        record.oldDataJSON = jsonString(dict["oldData"])
        record.newDataJSON = jsonString(dict["newData"])
        return record
    }

    // MARK: - 值类型兼容

    /// 云端导出里 num 是数字，price 多是字符串但也可能是数字，统一处理
    private static func number(_ value: Any?) -> Double? {
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String { return Double(s) }
        return nil
    }

    private static func stringValue(_ value: Any?) -> String {
        if let s = value as? String { return s }
        if let n = value as? NSNumber { return Formatters.num(n.doubleValue) }
        return ""
    }

    /// 处理 Mongo 扩展日期格式 {"$date": "2026-03-25T09:41:36.758Z"}
    private static func dateValue(_ value: Any?) -> Date? {
        if let s = value as? String {
            return iso8601WithFraction.date(from: s) ?? iso8601.date(from: s)
        }
        if let d = value as? [String: Any], let s = d["$date"] as? String {
            return iso8601WithFraction.date(from: s) ?? iso8601.date(from: s)
        }
        return nil
    }

    private static func jsonString(_ value: Any?) -> String? {
        guard let value,
              JSONSerialization.isValidJSONObject(value),
              let data = try? JSONSerialization.data(withJSONObject: value) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
