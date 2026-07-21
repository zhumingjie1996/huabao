import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// 数据管理页：导入云数据库导出的 JSONL 文件完成初始化；也可把本地数据按相同格式导出备份。
/// 导入自动识别商品 / 操作记录两种文件，按 _id 去重，可重复导入。
struct ImportView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var products: [Product]
    @Query private var records: [OperationRecord]

    @State private var viewModel = ImportViewModel()

    var body: some View {
        Form {
            Section("当前数据") {
                LabeledContent("商品", value: "\(products.count) 条")
                LabeledContent("操作记录", value: "\(records.count) 条")
            }
            Section {
                Button {
                    viewModel.showPicker = true
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isImporting {
                            ProgressView()
                        } else {
                            Label("选择导出文件导入", systemImage: "square.and.arrow.down")
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isImporting)
            } footer: {
                Text("请选择从微信云开发数据库导出的 JSON 文件（商品 / 操作记录可一次全选）。已存在的记录会自动跳过，可放心重复导入。")
            }
            Section {
                Button {
                    viewModel.export(products: products, records: records)
                } label: {
                    HStack {
                        Spacer()
                        Label("导出全部数据", systemImage: "square.and.arrow.up")
                        Spacer()
                    }
                }
                .disabled(products.isEmpty && records.isEmpty)
            } footer: {
                Text("导出为与云开发数据库一致格式的两个 JSON 文件（商品 / 操作记录），可用于备份或重新导入。")
            }
        }
        .navigationTitle("数据管理")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("完成") { dismiss() }
            }
        }
        .fileImporter(
            isPresented: $viewModel.showPicker,
            allowedContentTypes: [.json, .plainText],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.importFiles(urls, context: context)
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $viewModel.showExporter) {
            ActivityView(items: viewModel.exportURLs)
        }
        .alert("导入结果", isPresented: Binding(
            get: { viewModel.resultText != nil },
            set: { if !$0 { viewModel.resultText = nil } }
        )) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.resultText ?? "")
        }
        .alert("提示", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
