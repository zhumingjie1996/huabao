import SwiftUI

/// 列表右侧的首字母索引条（类似系统通讯录）：点按或拖动快速跳转到对应分组
struct SectionIndexBar: View {
    let titles: [String]
    let onSelect: (String) -> Void

    private let rowHeight: CGFloat = 16
    private let verticalPadding: CGFloat = 4

    var body: some View {
        VStack(spacing: 2) {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 20, height: rowHeight - 2)
            }
        }
        .padding(.vertical, verticalPadding)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let index = Int((value.location.y - verticalPadding) / rowHeight)
                    guard titles.indices.contains(index) else { return }
                    onSelect(titles[index])
                }
        )
        .accessibilityLabel("首字母索引")
    }
}
