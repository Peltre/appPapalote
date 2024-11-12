import SwiftUI

struct SlidingOverlayCardView: View {
    @State private var dragOffset: CGFloat = 0 // Tracks the drag offset
    @State private var showOverlay = false // Tracks overlay visibility at rest
    private let cornerRadius: CGFloat = 30 // Corner radius for rounded corners
    
    var body: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width
            let frameHeight = frameWidth * 0.9 // Adjust the height as needed
            
            ZStack {
                // Main image
                Image("cat") // Replace with your image name
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameWidth, height: frameHeight)
                    .clipped()
                
                // Sliding overlay
                OverlayView()
                    .frame(width: frameWidth, height: frameHeight)
                    .background(.ultraThinMaterial)
                    .opacity(0.9) // Adjust opacity for translucency
                    .offset(x: showOverlay ? dragOffset : frameWidth + dragOffset) // Position the overlay
                    .animation(.easeInOut, value: showOverlay) // Animate in/out
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Apply rounded corners to the entire ZStack
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius) // Border around the rounded shape
                    .stroke(Color.white, lineWidth: 2)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dragAmount = value.translation.width
                        
                        // Show overlay: dragging left from the image
                        if !showOverlay && dragAmount < 0 {
                            dragOffset = max(dragAmount, -frameWidth)
                        }
                        // Hide overlay: dragging right from the overlay
                        else if showOverlay && dragAmount > 0 {
                            dragOffset = min(dragAmount, frameWidth)
                        }
                    }
                    .onEnded { value in
                        // Show if dragged more than 1/4 of frame to the left, hide if dragged more than 1/4 of frame to the right
                        let shouldShow = value.translation.width < -frameWidth / 4
                        let shouldHide = value.translation.width > frameWidth / 4
                        
                        if shouldShow {
                            showOverlay = true
                        } else if shouldHide {
                            showOverlay = false
                        }
                        
                        // Reset dragOffset since we use showOverlay to control the final position
                        dragOffset = 0
                    }
            )
        }
        .padding(.top,52)
    }
}

struct OverlayView: View {
    var body: some View {
        ZStack {
            // Translucent background with Material
            Rectangle()
                .fill(.ultraThinMaterial)
            
            // Overlay text
            Text("Your Overlay Text Here")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding()
        }
    }
}

struct SlidingOverlayCardView_Previews: PreviewProvider {
    static var previews: some View {
        SlidingOverlayCardView()
            .frame(width: UIScreen.screenWidth-40, height: UIScreen.screenHeight/2) // Example frame size
    }
}

func tarjetaView(tarjeta: Tarjeta, actividad: Actividad2) -> some View {
    let cardWidth: CGFloat = UIScreen.screenWidth - 50 // Adjust width as needed
    
    switch tarjeta.tipo {
    case 1:
        return AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.7))
                    .frame(minWidth: cardWidth)
                    .shadow(color: Color(white: 0.96), radius: 2)
                Text(tarjeta.texto ?? "")
                    .font(.headline)
                    .padding()
            }
                .frame(width: cardWidth) // Width applied to the container
        )
    case 2:
        return AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.7))
                    .shadow(color: Color(white: 0.96), radius: 2)
                    .frame(minWidth: cardWidth)
                HStack {
                    Text(tarjeta.texto ?? "")
                        .font(.headline)
                        .padding()
                    
                    if let imagenUrl = tarjeta.imagenUrl, let url = URL(string: imagenUrl) {
                        CacheAsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100) // Placeholder size
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            case .failure(let error):
                                Text("Error loading image: \(error)")
                                    .frame(width: 100, height: 100) // Placeholder size
                            @unknown default:
                                fatalError()
                            }
                        }
                    }
                }
                .padding(8)
            }
                .frame(width: cardWidth) // Width applied to the container
        )
    case 3:
        return AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.7))
                    .shadow(color: Color(white: 0.96), radius: 2)
                    .frame(minWidth: cardWidth)
                HStack {
                    if let imagenUrl = tarjeta.imagenUrl, let url = URL(string: imagenUrl) {
                        CacheAsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100) // Placeholder size
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            case .failure(let error):
                                Text("Error loading image: \(error)")
                                    .frame(width: 100, height: 100) // Placeholder size
                            @unknown default:
                                fatalError()
                            }
                        }
                    }
                    Text(tarjeta.texto ?? "")
                        .font(.headline)
                        .padding()
                }
                .padding(8)
            }
                .frame(width: cardWidth) // Width applied to the container
        )
    case 4:
        return AnyView(
            ZStack {
                // Background circle
                Circle()
                    .fill(colores[actividad.idZona]!) // Use the color for the background
                    .frame(width: cardWidth, height: cardWidth) // Slightly larger than the image
                
                // Image
                if let imagenUrl = tarjeta.imagenUrl, let url = URL(string: imagenUrl) {
                    CacheAsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: cardWidth, height: cardWidth) // Placeholder size
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle()) // Ensure the image is also circular
                                .frame(width: cardWidth - 20, height: cardWidth - 20) // Set size for the image
                        case .failure(let error):
                            Text("Error loading image: \(error)")
                                .frame(width: cardWidth, height: cardWidth) // Placeholder size
                        @unknown default:
                            fatalError()
                        }
                    }
                }
            }
                .frame(width: cardWidth, height: cardWidth) // Width applied to the container
                .padding(.vertical,20)
        )
    default:
        return AnyView(EmptyView())
    }
}
