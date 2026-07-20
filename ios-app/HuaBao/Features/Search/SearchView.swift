import SwiftUI
import SwiftData

/// 「搜索」页：按 名称 / 名称代码 / 规格 模糊匹配（对应云端 searchProduction）
struct SearchView: View {
    @Query private var products: [Product]
    @State private var keyword = ""

    private var results: [Product] {
        let key = keyword.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return [] }
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(key)
                || $0.nameCode.localizedCaseInsensitiveContains(key)
                || $0.spec.localizedCaseInsensitiveContains(key)
        }
        .prefix(20)
        .map { $0 }
    }

    var body: some View {
        List(results) { product in
            NavigationLink(destination: ProductDetailView(product: product)) {
                ProductRow(product: product)
            }
        }
        .navigationTitle("搜索")
        .searchable(text: $keyword, prompt: "名称 / 代码 / 规格")
        .overlay {
            if keyword.isEmpty {
                ContentUnavailableView("输入关键词搜索", systemImage: "magnifyingglass")
            } else if results.isEmpty {
                ContentUnavailableView("无匹配结果", systemImage: "magnifyingglass")
            }
        }
    }
}
