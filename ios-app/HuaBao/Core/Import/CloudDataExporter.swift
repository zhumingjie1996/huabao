import Foundation

/// 把本地数据导出为与微信云开发数据库导出一致的 JSONL 格式：
/// 每行一个 JSON 对象，日期为 {"$date": "ISO-8601"} 扩展格式。
/// 导出的文件可以直接被 CloudDataImporter 重新导入。
enum CloudDataExporter {

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// 生成 productionList.json 和 operationList.json 两个临时文件，返回其 URL（供分享面板使用）
    static func exportFiles(products: [Product], records: [OperationRecord]) throws -> [URL] {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("huabao-export-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let productsURL = dir.appendingPathComponent("productionList.json")
        let recordsURL = dir.appendingPathComponent("operationList.json")

        let productLines = products.map(productLine).joined(separator: "\n")
        let recordLines = records
            .sorted { $0.date < $1.date }
            .map(recordLine)
            .joined(separator: "\n")

        try productLines.write(to: productsURL, atomically: true, encoding: .utf8)
        try recordLines.write(to: recordsURL, atomically: true, encoding: .utf8)

        return [productsURL, recordsURL]
    }

    // MARK: - 序列化

    private static func productLine(_ product: Product) -> String {
        jsonLine([
            "_id": product.id,
            "initials": product.initials,
            "name": product.name,
            "nameCode": product.nameCode,
            "num": product.num,
            "price": product.price,
            "spec": product.spec,
            "unit": product.unit
        ])
    }

    private static func recordLine(_ record: OperationRecord) -> String {
        var dict: [String: Any] = [
            "_id": record.id,
            "operateType": record.operateType,
            "operateName": record.operateName,
            "date": ["$date": iso8601.string(from: record.date)]
        ]
        if let productionId = record.productionId { dict["productionId"] = productionId }
        if let name = record.name { dict["name"] = name }
        if let spec = record.spec { dict["spec"] = spec }
        if let unit = record.unit { dict["unit"] = unit }
        if let num = record.num { dict["num"] = num }
        if let price = record.price { dict["price"] = price }
        if let oldDataJSON = record.oldDataJSON, let old = decodeJSON(oldDataJSON) {
            dict["oldData"] = old
        }
        if let newDataJSON = record.newDataJSON, let new = decodeJSON(newDataJSON) {
            dict["newData"] = new
        }
        return jsonLine(dict)
    }

    private static func jsonLine(_ dict: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.withoutEscapingSlashes]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    private static func decodeJSON(_ json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}
