import SwiftUI

/// 商品详情页：查看并修改全部字段（名称/名称代码/规格/单位/数量/价格），删除商品（对应小程序 pages/productionDetail）
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
                HStack {
                    Text("名称")
                    Spacer()
                    TextField("名称", text: $viewModel.name)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("名称代码")
                    Spacer()
                    TextField("名称代码", text: $viewModel.nameCode)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("规格")
                    Spacer()
                    TextField("规格", text: $viewModel.spec)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("单位")
                    Spacer()
                    TextField("单位", text: $viewModel.unit)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section("库存与价格") {
                HStack {
                    Text("数量")
                    Spacer()
                    TextField("数量", text: $viewModel.numText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Stepper("", value: Binding(
                        get: { viewModel.parsedNum ?? 0 },
                        set: { viewModel.numText = Formatters.num($0) }
                    ), step: 1)
                    .labelsHidden()
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
                .disabled(!viewModel.isChanged)
            }
        }
        // 点击空白处收起键盘（让当前输入框失去焦点）；
        // 用 simultaneousGesture 避免拦截按钮的点击事件
        .simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .navigationTitle(product.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("删除", systemImage: "trash", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
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
