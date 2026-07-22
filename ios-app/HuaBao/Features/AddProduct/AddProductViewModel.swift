import Foundation
import SwiftData

@Observable
final class AddProductViewModel {
    var name = ""
    var nameCode = ""
    var spec = ""
    var num = ""
    var unit = ""
    var price = ""

    var alertMessage: String?
    var isSuccess = false

    /// 对应小程序 commit：全必填校验 -> name+spec 查重 -> 插入商品并写 add 操作记录
    func commit(context: ModelContext) {
        let fields = [name, nameCode, spec, num, unit, price].map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        guard fields.allSatisfy({ !$0.isEmpty }) else {
            showAlert("请完善信息", success: false)
            return
        }
        guard let numValue = Double(fields[3]) else {
            showAlert("数量必须是数字", success: false)
            return
        }

        let nameValue = fields[0]
        let specValue = fields[2]
        var descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { $0.name == nameValue && $0.spec == specValue }
        )
        descriptor.fetchLimit = 1

        do {
            if try context.fetchCount(descriptor) > 0 {
                showAlert("勿重复添加", success: false)
                return
            }

            let product = Product(
                name: nameValue,
                nameCode: fields[1],
                initials: String(fields[1].prefix(1)).uppercased(),
                spec: specValue,
                num: numValue,
                price: fields[5],
                unit: fields[4]
            )
            context.insert(product)

            let record = OperationRecord(
                productionId: product.id,
                operateType: "add",
                operateName: "新增"
            )
            record.name = product.name
            record.spec = product.spec
            record.unit = product.unit
            record.num = product.num
            record.price = product.price
            context.insert(record)

            try context.save()
            showAlert("添加成功", success: true)
            clear()
        } catch {
            showAlert("保存失败：\(error.localizedDescription)", success: false)
        }
    }

    private func showAlert(_ message: String, success: Bool) {
        alertMessage = message
        isSuccess = success
    }

    private func clear() {
        name = ""
        nameCode = ""
        spec = ""
        num = ""
        unit = ""
        price = ""
    }
}
