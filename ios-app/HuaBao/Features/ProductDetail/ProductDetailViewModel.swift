import Foundation
import SwiftData

@Observable
final class ProductDetailViewModel {
    var name: String
    var nameCode: String
    var spec: String
    var unit: String
    /// 数量用字符串持有，支持直接输入；Stepper 通过解析值增减
    var numText: String
    var price: String

    private let originalName: String
    private let originalNameCode: String
    private let originalSpec: String
    private let originalUnit: String
    private let originalNum: Double
    private let originalPrice: String

    /// 输入的数量解析结果，非法输入为 nil
    var parsedNum: Double? {
        Double(numText.trimmingCharacters(in: .whitespaces))
    }

    /// 对应小程序 isChange：改动过才允许提交
    var isChanged: Bool {
        name != originalName || nameCode != originalNameCode ||
        spec != originalSpec || unit != originalUnit ||
        parsedNum != originalNum || price != originalPrice
    }

    init(product: Product) {
        self.name = product.name
        self.nameCode = product.nameCode
        self.spec = product.spec
        self.unit = product.unit
        self.numText = Formatters.num(product.num)
        self.price = product.price
        self.originalName = product.name
        self.originalNameCode = product.nameCode
        self.originalSpec = product.spec
        self.originalUnit = product.unit
        self.originalNum = product.num
        self.originalPrice = product.price
    }

    /// 对应云端 updataProduction：更新商品字段，并写一条带 oldData/newData 的 updata 记录
    func commit(product: Product, context: ModelContext) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedNameCode = nameCode.trimmingCharacters(in: .whitespaces)
        let trimmedSpec = spec.trimmingCharacters(in: .whitespaces)
        let trimmedUnit = unit.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !trimmedNameCode.isEmpty,
              !trimmedSpec.isEmpty, !trimmedUnit.isEmpty else {
            throw CommitError.emptyField
        }
        guard let numValue = parsedNum else {
            throw CommitError.invalidNum
        }

        let oldData: [String: Any] = [
            "_id": product.id,
            "initials": product.initials,
            "name": product.name,
            "nameCode": product.nameCode,
            "num": product.num,
            "price": product.price,
            "spec": product.spec,
            "unit": product.unit
        ]
        let newData: [String: Any] = [
            "id": product.id,
            "name": trimmedName,
            "nameCode": trimmedNameCode,
            "spec": trimmedSpec,
            "unit": trimmedUnit,
            "num": numValue,
            "price": price
        ]

        product.name = trimmedName
        product.nameCode = trimmedNameCode
        product.initials = String(trimmedNameCode.prefix(1)).uppercased()
        product.spec = trimmedSpec
        product.unit = trimmedUnit
        product.num = numValue
        product.price = price

        let record = OperationRecord(
            productionId: product.id,
            operateType: "updata",
            operateName: "修改"
        )
        record.oldDataJSON = Self.jsonString(oldData)
        record.newDataJSON = Self.jsonString(newData)
        context.insert(record)

        try context.save()
    }

    /// 对应云端 removeProduction：删除商品并写一条 delete 记录（带商品快照）
    func delete(product: Product, context: ModelContext) throws {
        let record = OperationRecord(
            productionId: product.id,
            operateType: "delete",
            operateName: "删除"
        )
        record.name = product.name
        record.spec = product.spec
        record.unit = product.unit
        record.num = product.num
        record.price = product.price
        context.insert(record)

        context.delete(product)
        try context.save()
    }

    static func jsonString(_ dict: [String: Any]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    enum CommitError: LocalizedError {
        case emptyField
        case invalidNum

        var errorDescription: String? {
            switch self {
            case .emptyField: return "请完善信息"
            case .invalidNum: return "数量必须是数字"
            }
        }
    }
}
