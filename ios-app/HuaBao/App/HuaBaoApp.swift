import SwiftUI
import SwiftData

@main
struct HuaBaoApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Product.self, OperationRecord.self])
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ProductListView()
            }
            .tabItem {
                Label("全部", systemImage: "tray.full")
            }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("搜索", systemImage: "magnifyingglass")
            }

            NavigationStack {
                AddProductView()
            }
            .tabItem {
                Label("增加", systemImage: "plus.circle")
            }

            NavigationStack {
                RecordsView()
            }
            .tabItem {
                Label("记录", systemImage: "clock")
            }
        }
    }
}
