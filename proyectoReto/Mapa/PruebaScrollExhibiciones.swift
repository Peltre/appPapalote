import SwiftUI

struct ScrollableCardStack<Data, Content>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    @Environment(\.layoutDirection) var layoutDirection
    @State private var currentIndex: Int = 0
    @State private var isDragging: Bool = false
    
    private let data: Data
    @ViewBuilder private let content: (Data.Element) -> Content
    
    public init(data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollViewReader { scrollProxy in
                if #available(iOS 17.0, *) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Array(data.enumerated()), id: \.element.id) { (index, element) in
                                GeometryReader { proxy in
                                    content(element)
                                        .padding(.horizontal, 64)
                                        .frame(width: size.width)
                                        .id(index)
                                        .scaleEffect(scale(for: index, proxy: proxy))
                                        .rotationEffect(rotation(for: index, proxy: proxy))
                                        .offset(x: offset(for: index, proxy: proxy))
                                        .zIndex(zIndex(for: index))
                                        .contentShape(Rectangle()) // Makes entire area tappable
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                currentIndex = index
                                                scrollProxy.scrollTo(index, anchor: .center)
                                            }
                                        }
                                        .simultaneousGesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { _ in
                                                    isDragging = true
                                                }
                                                .onEnded { value in
                                                    isDragging = false
                                                    if abs(value.translation.width) > size.width * 0.2 {
                                                        let newIndex = value.translation.width > 0 ?
                                                        max(currentIndex - 1, 0) :
                                                        min(currentIndex + 1, Array(data).count - 1)
                                                        
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                            currentIndex = newIndex
                                                            scrollProxy.scrollTo(newIndex, anchor: .center)
                                                        }
                                                    }
                                                }
                                        )
                                }
                                .frame(width: size.width)
                            }
                        }
                        .padding(.vertical, 16)
                        .scrollDisabled(isDragging)
                    }
                    .scrollTargetBehavior(.paging)
                } else {
                    // Fallback on earlier versions
                }
            }
            .frame(height: 410)
        }
    }
    
    private func progress(for index: Int, proxy: GeometryProxy) -> CGFloat {
        if #available(iOS 17.0, *) {
            let scrollViewWidth = proxy.bounds(of: .scrollView)?.width ?? 0
            let minX = proxy.frame(in: .scrollView).minX
            let progress = minX / scrollViewWidth
            
            return layoutDirection == .rightToLeft ? -progress : progress
        } else {
            // Fallback on earlier versions
        }
        return CGFloat(1)
    }
    
    private func scale(for index: Int, proxy: GeometryProxy) -> CGFloat {
        let progress = progress(for: index, proxy: proxy)
        return 1 - (abs(progress) * 0.1)
    }
    
    private func rotation(for index: Int, proxy: GeometryProxy) -> Angle {
        let progress = progress(for: index, proxy: proxy)
        return .degrees(progress * 5)
    }
    
    private func offset(for index: Int, proxy: GeometryProxy) -> CGFloat {
        let progress = progress(for: index, proxy: proxy)
        let baseOffset = progress * 8
        return layoutDirection == .rightToLeft ? -baseOffset : baseOffset
    }
    
    private func zIndex(for index: Int) -> Double {
        let total = Array(data).count
        if index == currentIndex {
            return Double(total)
        } else if index > currentIndex {
            return Double(total - (index - currentIndex))
        } else {
            return Double(total - (currentIndex - index))
        }
    }
}
// Demo implementation remains the same
struct DemoItem: Identifiable {
    var id = UUID()
    let name: String
    let color: Color
}

struct DemoView: View {
    var body: some View {
        let colors = [
            DemoItem(name: "Red", color: .red),
            DemoItem(name: "Green", color: .green),
            DemoItem(name: "Yellow", color: .yellow),
            DemoItem(name: "Blue", color: .blue),
            DemoItem(name: "Cyan", color: .cyan),
            DemoItem(name: "Purple", color: .purple)
        ]
        
        VStack {
            Text("Scrollable Card Stack SwiftUI")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Scrollable, RTL Support")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            ScrollableCardStack(data: colors) { namedColor in
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(namedColor.color)
                    .overlay(
                        Text(namedColor.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .frame(width: 270)
            }
            
            Spacer()
            
            Text("bento.me/codelab")
                .foregroundStyle(.blue)
        }
    }
}

#Preview{
    DemoView()
}
