import SwiftUI
import SwiftData

/// 「全部」页：按首字母分组索引列表 + 底部总条数，工具栏提供数据导入入口
struct ProductListView: View {
    @Query(sort: [SortDescriptor(\Product.initials), SortDescriptor(\Product.nameCode), SortDescriptor(\Product.name)])
    private var products: [Product]

    @State private var showImport = false

    private var grouped: [(String, [Product])] {
        Dictionary(grouping: products, by: { $0.initials })
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }

    var body: some View {
        List {
            ForEach(grouped, id: \.0) { initial, items in
                Section(header: Text(initial)) {
                    ForEach(items) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            ProductRow(product: product)
                        }
                    }
                }
            }
        }
        .navigationTitle("华宝五金")
        .safeAreaInset(edge: .bottom) {
            if !products.isEmpty {
                Text("共 \(products.count) 条数据")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(.bar)
            }
        }
        .overlay {
            if products.isEmpty {
                ContentUnavailableView("暂无商品", systemImage: "tray", description: Text("点击右上角导入云数据库导出文件"))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showImport = true
                } label: {
                    Label("导入数据", systemImage: "square.and.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showImport) {
            NavigationStack {
                ImportView()
            }
        }
    }
}
