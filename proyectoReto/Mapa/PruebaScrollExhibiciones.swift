import SwiftUI

struct ScrollableCardStack<Data, Content>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    @Environment(\.layoutDirection) var layoutDirection
    
    private let data: Data
    @ViewBuilder private let content: (Data.Element) -> Content
    
    public init(data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollView(.horizontal) {
                if #available(iOS 17.0, *) {
                    HStack(spacing: 0) {
                        ForEach(Array(data.enumerated()), id: \.element.id) { (index, element) in
                            content(element)
                                .padding(.horizontal, 64)
                                .frame(width: size.width)
                                .visualEffect { content, geometryProxy in
                                    content
                                        .scaleEffect(scale(geometryProxy, scale: 0.1), anchor: .trailing)
                                        .rotationEffect(rotation(geometryProxy, rotation: 2))
                                        .offset(x: minX(geometryProxy))
                                        .offset(x: excessMinX(geometryProxy, offset: 5)) // lo que sobre sale
                                }
                                .zIndex(zIndex(for: index))
                        }
                    }
                    .padding(.vertical, 16)
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)
                } else {
                    // Fallback on earlier versions
                }
            }
            .frame(height: 410)
        }
    }
    
    private func zIndex(for index: Int) -> Double {
        let maxIndex = data.count - 1
        let reversedIndex = maxIndex - index
        return Double(reversedIndex)
    }
    
    private func minX(_ proxy: GeometryProxy) -> CGFloat {
        if #available(iOS 17.0, *) {
            let minX = proxy.frame(in: .scrollView).minX
            return minX < 0 ? 0 : -minX
        } else {
            return 0 // Fallback for earlier versions
        }
    }
    
    private func progress(_ proxy: GeometryProxy, limit: CGFloat = 2) -> CGFloat {
        if #available(iOS 17.0, *) {
            let maxX = proxy.frame(in: .scrollView(axis: .horizontal)).maxX
            let width = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? 0
            let progress = (maxX / width) - 1.0
            if layoutDirection == .rightToLeft {
                return min(abs(progress), limit)
            } else {
                return min(progress, limit)
            }
        } else {
            return 0 // Fallback for earlier versions
        }
    }
    
    private func scale(_ proxy: GeometryProxy, scale: CGFloat = 0.1) -> CGFloat {
        let progress = progress(proxy)
        return 1 - (progress * scale)
    }
    
    private func excessMinX(_ proxy: GeometryProxy, offset: CGFloat = 10) -> CGFloat {
        let progress = progress(proxy)
        return progress * offset
    }
    
    private func rotation(_ proxy: GeometryProxy, rotation: CGFloat = 5) -> Angle {
        let progress = progress(proxy)
        return .init(degrees: progress * rotation)
    }
}

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
                    .onTapGesture {
                        print("Click: \(namedColor.name)")
                    }
            }
            
            Spacer()
            
            Text("bento.me/codelab")
                .foregroundStyle(.blue)
        }
    }
}

// Preview for DemoView
struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}
