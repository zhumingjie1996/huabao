import SwiftUI
import SwiftData

/// 「记录」页：操作记录列表，支持类型 / 时间 / 排序筛选（对应小程序 pages/record）
struct RecordsView: View {
    @Query(sort: \OperationRecord.date, order: .reverse)
    private var records: [OperationRecord]

    @State private var viewModel = RecordsViewModel()
    @State private var showCustomDateSheet = false
    @State private var selectedUpdata: OperationRecord?

    private var filtered: [OperationRecord] {
        viewModel.apply(to: records)
    }

    var body: some View {
        List(filtered) { record in
            RecordRow(record: record)
                .contentShape(Rectangle())
                .onTapGesture {
                    if record.operateType == "updata" {
                        selectedUpdata = record
                    }
                }
        }
        .navigationTitle("记录")
        .safeAreaInset(edge: .top) {
            VStack(spacing: 8) {
                Picker("类型", selection: $viewModel.type) {
                    ForEach(OperateType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Menu {
                        ForEach(TimeScope.allCases) { scope in
                            Button(scope.title) {
                                viewModel.timeScope = scope
                                if scope == .custom { showCustomDateSheet = true }
                            }
                        }
                    } label: {
                        Label(viewModel.timeScope.title, systemImage: "calendar")
                            .font(.subheadline)
                    }
                    Spacer()
                    Button {
                        viewModel.ascending.toggle()
                    } label: {
                        Label(viewModel.ascending ? "正序" : "倒序",
                              systemImage: viewModel.ascending ? "arrow.up" : "arrow.down")
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView("暂无记录", systemImage: "clock")
            }
        }
        .sheet(isPresented: $showCustomDateSheet) {
            NavigationStack {
                Form {
                    DatePicker("开始日期", selection: $viewModel.customStart, displayedComponents: .date)
                    DatePicker("结束日期", selection: $viewModel.customEnd, displayedComponents: .date)
                }
                .navigationTitle("自定义区间")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { showCustomDateSheet = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $selectedUpdata) { record in
            UpdataDetailView(record: record)
                .presentationDetents([.medium])
        }
    }
}

struct RecordRow: View {
    let record: OperationRecord

    private var tagColor: Color {
        switch record.operateType {
        case "add": return .green
        case "delete": return .red
        default: return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(RecordsViewModel.name(of: record))
                let spec = RecordsViewModel.spec(of: record)
                if !spec.isEmpty {
                    Tag(text: spec)
                }
                ColoredTag(text: record.operateName, color: tagColor)
                Spacer()
                if record.operateType == "add", let num = record.num {
                    Text(Formatters.num(num) + (record.unit ?? ""))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if record.operateType == "updata" {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Text(Formatters.recordDate.string(from: record.date))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// updata 记录的新旧数据对比（对应小程序 showUpdataDetail）
struct UpdataDetailView: View {
    let record: OperationRecord

    private var oldData: [String: Any]? { RecordsViewModel.decodeDict(record.oldDataJSON) }
    private var newData: [String: Any]? { RecordsViewModel.decodeDict(record.newDataJSON) }

    private func numText(_ dict: [String: Any]?) -> String {
        guard let n = dict?["num"] as? NSNumber else { return "-" }
        return Formatters.num(n.doubleValue)
    }

    private func priceText(_ dict: [String: Any]?) -> String {
        (dict?["price"] as? String) ?? "-"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("商品") {
                    LabeledContent("名称", value: RecordsViewModel.name(of: record))
                    LabeledContent("规格", value: RecordsViewModel.spec(of: record))
                    LabeledContent("时间", value: Formatters.recordDate.string(from: record.date))
                }
                Section("修改前") {
                    LabeledContent("数量", value: numText(oldData))
                    LabeledContent("价格", value: priceText(oldData))
                }
                Section("修改后") {
                    LabeledContent("数量", value: numText(newData))
                    LabeledContent("价格", value: priceText(newData))
                }
            }
            .navigationTitle("修改详情")
        }
    }
}
