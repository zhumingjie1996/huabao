import SwiftUI

/// 列表右侧的首字母索引条（类似系统通讯录）：点按或拖动快速跳转到对应分组
struct SectionIndexBar: View {
    let titles: [String]
    let onSelect: (String) -> Void

    private let rowHeight: CGFloat = 16
    private let verticalPadding: CGFloat = 6

    @State private var activeTitle: String?

    var body: some View {
        VStack(spacing: 1) {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(title == activeTitle ? Color.white : Color.accentColor)
                    .frame(width: 22, height: rowHeight - 1)
                    .background {
                        if title == activeTitle {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 16, height: 16)
                        }
                    }
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, 2)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let index = Int((value.location.y - verticalPadding) / rowHeight)
                    guard titles.indices.contains(index) else { return }
                    let title = titles[index]
                    if title != activeTitle {
                        activeTitle = title
                        onSelect(title)
                    }
                }
                .onEnded { _ in
                    activeTitle = nil
                }
        )
        .accessibilityLabel("首字母索引")
    }
}
