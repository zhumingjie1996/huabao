import SwiftUI

/// 商品行：名称 + spec 标签 + 数量单位标签，复刻小程序样式
struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 8) {
            Text(product.name)
            if !product.spec.isEmpty {
                Tag(text: product.spec)
            }
            Tag(text: Formatters.num(product.num) + product.unit)
        }
    }
}

struct Tag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
}

struct ColoredTag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color)
            .clipShape(Capsule())
    }
}
