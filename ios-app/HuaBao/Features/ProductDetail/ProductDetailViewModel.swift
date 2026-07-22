import Foundation
import SwiftData

@Observable
final class ProductDetailViewModel {
    var num: Double
    var price: String

    private let originalNum: Double
    private let originalPrice: String

    /// 对应小程序 isChange：改动过才允许提交
    var isChanged: Bool {
        num != originalNum || price != originalPrice
    }

    init(product: Product) {
        self.num = product.num
        self.price = product.price
        self.originalNum = product.num
        self.originalPrice = product.price
    }

    /// 对应云端 updataProduction：更新 num/price，并写一条带 oldData/newData 的 updata 记录
    func commit(product: Product, context: ModelContext) throws {
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
            "num": num,
            "price": price
        ]

        product.num = num
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
}
