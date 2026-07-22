import SwiftUI
import SwiftData

/// 清除记录页：全部清除 / 快捷时间段（N 天前）/ 自定义区间，仅清除操作记录，不影响商品数据
struct ClearRecordsView: View {
    enum ClearMode: String, CaseIterable, Identifiable {
        case quick
        case custom
        case all

        var id: String { rawValue }

        var title: String {
            switch self {
            case .quick: return "快捷清除"
            case .custom: return "自定义区间"
            case .all: return "全部清除"
            }
        }
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var records: [OperationRecord]

    @State private var mode: ClearMode = .quick
    @State private var quickDays = 30
    @State private var customStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var customEnd = Date()
    @State private var showConfirm = false
    @State private var errorMessage: String?

    private let quickOptions = [1, 7, 30, 90, 365]

    private var matched: [OperationRecord] {
        switch mode {
        case .all:
            return records
        case .quick:
            let cutoff = Calendar.current.date(byAdding: .day, value: -quickDays, to: Date()) ?? Date()
            return records.filter { $0.date < cutoff }
        case .custom:
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: customStart)
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: customEnd)) ?? customEnd
            return records.filter { $0.date >= start && $0.date < end }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("方式", selection: $mode) {
                    ForEach(ClearMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if mode == .quick {
                    Section("清除多久之前的记录") {
                        ForEach(quickOptions, id: \.self) { days in
                            Button {
                                quickDays = days
                            } label: {
                                HStack {
                                    Text(days >= 365 ? "1 年前" : "\(days) 天前")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if quickDays == days {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                        }
                    }
                }

                if mode == .custom {
                    Section("时间区间") {
                        DatePicker("开始日期", selection: $customStart, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                        DatePicker("结束日期", selection: $customEnd, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("清除 \(matched.count) 条记录")
                            Spacer()
                        }
                    }
                    .disabled(matched.isEmpty)
                } footer: {
                    Text("仅清除操作记录，商品数据不受影响。清除后不可恢复。")
                }
            }
            .navigationTitle("清除记录")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .confirmationDialog("确定清除 \(matched.count) 条记录？", isPresented: $showConfirm, titleVisibility: .visible) {
                Button("清除", role: .destructive) {
                    clear()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("清除后不可恢复")
            }
            .alert("提示", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func clear() {
        matched.forEach { context.delete($0) }
        do {
            try context.save()
            dismiss()
        } catch {
            errorMessage = "清除失败：\(error.localizedDescription)"
        }
    }
}
