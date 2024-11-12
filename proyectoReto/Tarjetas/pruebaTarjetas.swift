import SwiftUI

struct SlidingOverlayCardView: View {
    @State private var dragOffset: CGFloat = 0
    @State private var showOverlay = false
    private let cornerRadius: CGFloat = 30
    var question: Question
    
    var body: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width
            let frameHeight = frameWidth * 0.9
            
            ZStack {
                // Main image
                Image("cat")
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
                    .clipped()
                
                // Sliding overlay
                OverlayView(question: question)
                    .frame(width: frameWidth, height: frameHeight)
                    .background(.ultraThinMaterial)
                    .opacity(0.9)
                    .offset(x: showOverlay ? dragOffset : frameWidth + dragOffset)
                    .animation(.easeInOut, value: showOverlay)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { value in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            // Handle horizontal drag
                            if !showOverlay && value.translation.width < 0 {
                                dragOffset = max(value.translation.width, -frameWidth)
                            } else if showOverlay && value.translation.width > 0 {
                                dragOffset = min(value.translation.width, frameWidth)
                            }
                        }
                    }
                    .onEnded { value in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            let shouldShow = value.translation.width < -frameWidth / 4
                            let shouldHide = value.translation.width > frameWidth / 4
                            
                            if shouldShow {
                                showOverlay = true
                            } else if shouldHide {
                                showOverlay = false
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
    }
}


struct OverlayView: View {
    var question: Question
    
    var body: some View {
        ZStack {
            // Translucent background with Material
            Rectangle()
                .fill(.ultraThinMaterial)
            
            // Overlay text
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
                
                VStack {
                    Text(question.respuesta1)
                    Text(question.respuesta2)
                    Text(question.respuesta3)
                    Text(question.respuesta4)
                }
                .padding(.top)
            }
        }
    }
}
