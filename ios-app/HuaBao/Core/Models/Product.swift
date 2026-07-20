import Foundation
import SwiftData

/// 商品，对应云开发集合 productionList。
/// id 沿用云端 `_id`，新增商品本地生成 UUID。
@Model
final class Product {
    @Attribute(.unique) var id: String
    var name: String
    var nameCode: String
    var initials: String
    var spec: String
    var num: Double
    /// 云端价格就是字符串（如 "6"、"2.5"），保持原样
    var price: String
    var unit: String

    init(id: String = UUID().uuidString,
         name: String,
         nameCode: String,
         initials: String,
         spec: String,
         num: Double,
         price: String,
         unit: String) {
        self.id = id
        self.name = name
        self.nameCode = nameCode
        self.initials = initials
        self.spec = spec
        self.num = num
        self.price = price
        self.unit = unit
    }
}
