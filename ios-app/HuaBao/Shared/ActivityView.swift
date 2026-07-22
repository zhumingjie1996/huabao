import SwiftUI
import UIKit

/// 系统分享面板的 SwiftUI 封装，用于把导出文件分享 / 存储到「文件」
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
