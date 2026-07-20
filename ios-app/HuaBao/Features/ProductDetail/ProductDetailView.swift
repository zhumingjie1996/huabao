import SwiftUI

/// 商品详情页：查看全部字段，修改数量/价格，删除商品（对应小程序 pages/productionDetail）
struct ProductDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let product: Product
    @State private var viewModel: ProductDetailViewModel
    @State private var showDeleteConfirm = false
    @State private var alertMessage: String?

    init(product: Product) {
        self.product = product
        _viewModel = State(initialValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        Form {
            Section("商品信息") {
                LabeledContent("名称", value: product.name)
                LabeledContent("名称代码", value: product.nameCode)
                LabeledContent("规格", value: product.spec)
                LabeledContent("单位", value: product.unit)
            }
            Section("库存与价格") {
                Stepper(value: $viewModel.num, step: 1) {
                    HStack {
                        Text("数量")
                        Spacer()
                        Text(Formatters.num(viewModel.num))
                            .foregroundStyle(.secondary)
                    }
                }
                HStack {
                    Text("价格")
                    Spacer()
                    TextField("价格", text: $viewModel.price)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
            }
            if viewModel.isChanged {
                Section {
                    Button("提交修改") {
                        do {
                            try viewModel.commit(product: product, context: context)
                            viewModel = ProductDetailViewModel(product: product)
                            alertMessage = "修改成功"
                        } catch {
                            alertMessage = "保存失败：\(error.localizedDescription)"
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Section {
                Button("删除商品", role: .destructive) {
                    showDeleteConfirm = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(product.name)
        .confirmationDialog("确定删除？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) {
                do {
                    try viewModel.delete(product: product, context: context)
                    dismiss()
                } catch {
                    alertMessage = "删除失败：\(error.localizedDescription)"
                }
            }
            Button("取消", role: .cancel) {}
        }
        .alert("提示", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }
}
