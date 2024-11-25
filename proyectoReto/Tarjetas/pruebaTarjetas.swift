import SwiftUI

struct SlidingOverlayCardView: View {
    @State private var dragOffset: CGFloat = 0
    @State private var showOverlay = false
    @State private var isDragging = false // Track dragging state
    private let cornerRadius: CGFloat = 30
    var question: Question
    var imageUrl : String?
    
    var body: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width
            let frameHeight = frameWidth * 0.9
            
            ZStack {
                if let url = URL(string: imageUrl!) {
                    CacheAsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: frameWidth, height: frameHeight)
                                .clipped()
                        case .failure:
                            Image(systemName: "cat")
                                .resizable()
                                .scaledToFill()
                                .frame(width: frameWidth, height: frameHeight)
                                .clipped()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image("cat")
                        .resizable()
                        .scaledToFill()
                        .frame(width: frameWidth, height: frameHeight)
                        .clipped()
                }
                
                // Sliding overlay content with reversed arrow positions
                ZStack {
                    OverlayView(question: question)
                        .frame(width: frameWidth, height: frameHeight)
                        .background(.ultraThinMaterial)
                        .opacity(0.9)
                        .offset(x: showOverlay ? dragOffset : frameWidth + dragOffset)
                    
                    // Left Chevron to open overlay (on the right side of the image)
                    if !showOverlay {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .padding()
                                .opacity(isDragging ? 0 : 1.0) // Reduced opacity while dragging
                                .onTapGesture {
                                    showOverlay.toggle()
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDragging = true
                                            dragOffset = max(value.translation.width, -frameWidth)
                                        }
                                        .onEnded { _ in
                                            if dragOffset < -frameWidth / 2 {
                                                showOverlay = true
                                            }
                                            isDragging = false
                                            dragOffset = 0
                                        }
                                )
                        }
                    }
                    
                    // Right Chevron to close overlay (on the left side of the text overlay)
                    if showOverlay {
                        HStack {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                                .padding()
                                .opacity(isDragging ? 0 : 1.0) // Reduced opacity while dragging
                                .onTapGesture {
                                    showOverlay.toggle()
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDragging = true
                                            dragOffset = min(value.translation.width, frameWidth)
                                        }
                                        .onEnded { _ in
                                            if dragOffset > frameWidth / 2 {
                                                showOverlay = false
                                            }
                                            isDragging = false
                                            dragOffset = 0
                                        }
                                )
                            Spacer()
                        }
                    }
                }
                .animation(.easeInOut, value: showOverlay)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
        }
    }
}

struct OverlayView: View {
    var question: Question
    
    var body: some View {
        VStack {
            Text(question.titulo)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom)
            
            Text(question.texto)
                .font(.body)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            .padding(.top)
        }
    }
}
