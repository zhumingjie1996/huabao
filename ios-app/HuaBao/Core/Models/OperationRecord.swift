import Foundation
import SwiftData

/// 操作记录，对应云开发集合 operationList。
/// operateType: add / delete / updata；operateName: 新增 / 删除 / 修改。
/// add / delete 记录把商品字段快照平铺在自身；
/// updata 记录把云端 oldData / newData 原样存成 JSON 字符串，展示时再解码。
@Model
final class OperationRecord {
    @Attribute(.unique) var id: String
    var productionId: String?
    var operateType: String
    var operateName: String
    var date: Date

    // add / delete 的商品快照字段
    var name: String?
    var spec: String?
    var unit: String?
    var num: Double?
    var price: String?

    // updata 的新旧数据
    var oldDataJSON: String?
    var newDataJSON: String?

    init(id: String = UUID().uuidString,
         productionId: String? = nil,
         operateType: String,
         operateName: String,
         date: Date = Date()) {
        self.id = id
        self.productionId = productionId
        self.operateType = operateType
        self.operateName = operateName
        self.date = date
    }
}

enum OperateType: String, CaseIterable, Identifiable {
    case all
    case add
    case updata
    case delete

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .add: return "新增"
        case .updata: return "修改"
        case .delete: return "删除"
        }
    }
}
