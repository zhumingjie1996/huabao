import SwiftUI

/// 「增加」页：新增商品表单（对应小程序 pages/add）
struct AddProductView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = AddProductViewModel()

    var body: some View {
        Form {
            Section("商品信息") {
                TextField("名称（如：油石）", text: $viewModel.name)
                TextField("名称代码（如：Ys）", text: $viewModel.nameCode)
                TextField("规格（如：200㎜）", text: $viewModel.spec)
                TextField("单位（如：块）", text: $viewModel.unit)
            }
            Section("库存与价格") {
                TextField("数量", text: $viewModel.num)
                    .keyboardType(.decimalPad)
                TextField("价格", text: $viewModel.price)
                    .keyboardType(.decimalPad)
            }
            Section {
                Button("提交") {
                    viewModel.commit(context: context)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("增加")
        .alert(viewModel.isSuccess ? "成功" : "提示",
               isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
               )) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }
}
