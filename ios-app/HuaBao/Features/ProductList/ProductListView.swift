import SwiftUI
import SwiftData

/// 「全部」页：顶部搜索 + 按首字母分组索引列表 + 底部总条数，工具栏提供数据导入入口
struct ProductListView: View {
    @Query(sort: [SortDescriptor(\Product.initials), SortDescriptor(\Product.nameCode), SortDescriptor(\Product.name)])
    private var products: [Product]

    @State private var showImport = false
    @State private var showAdd = false
    @State private var keyword = ""

    /// 按 名称 / 名称代码 / 规格 模糊匹配（对应云端 searchProduction）
    private var filteredProducts: [Product] {
        let key = keyword.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return products }
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(key)
                || $0.nameCode.localizedCaseInsensitiveContains(key)
                || $0.spec.localizedCaseInsensitiveContains(key)
        }
    }

    private var grouped: [(String, [Product])] {
        Dictionary(grouping: filteredProducts, by: { $0.initials })
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }

    private var isSearching: Bool {
        !keyword.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(grouped, id: \.0) { initial, items in
                    Section(header: Text(initial)) {
                        ForEach(items) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductRow(product: product)
                            }
                        }
                    }
                    .id(initial)
                }
            }
            .overlay(alignment: .trailing) {
                if grouped.count > 1 {
                    SectionIndexBar(titles: grouped.map(\.0)) { title in
                        withAnimation {
                            proxy.scrollTo(title, anchor: .top)
                        }
                    }
                    .padding(.trailing, 6)
                }
            }
            .navigationTitle("华宝五金")
        .searchable(text: $keyword, placement: .navigationBarDrawer(displayMode: .always), prompt: "名称 / 代码 / 规格")
        .overlay {
            if products.isEmpty {
                ContentUnavailableView("暂无商品", systemImage: "tray", description: Text("点击右上角导入云数据库导出文件"))
            } else if isSearching && filteredProducts.isEmpty {
                ContentUnavailableView("无匹配结果", systemImage: "magnifyingglass")
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Label("增加", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showImport) {
            NavigationStack {
                ImportView()
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                AddProductView()
            }
        }
        }
    }
}
