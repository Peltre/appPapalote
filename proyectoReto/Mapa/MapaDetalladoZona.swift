import SwiftUI
import InteractiveMap

struct MapaDetalladoZona: View {
    var onSelectPath: (String) -> Void
    var idZona : Int = 6
    @State private var clickedPath = PathData()
    @State private var svgName = ""
    @State private var textScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var currentPosition: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 4.0
    
    var body: some View {
        NavigationStack{
            let colorFondo = colores[idZona]!
            let svgName = mapaDetallado[idZona]!
            ZStack{
                Button(action: {
                    onSelectPath("")
                    dismiss() // Cierra la vista actual
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .foregroundColor(.white)
                        .bold()
                        .padding(10)
                        .background(Color.black)
                        .clipShape(.circle)
                }
                .offset(x: -UIScreen.main.bounds.width/2 + 45, y: -UIScreen.screenHeight/2 + 60)
                .zIndex(2)
                
                GeometryReader { geometry in
                    ZStack {
                        // Borde exterior (más grande)
                        RoundedRectangle(cornerRadius: 40)
                            .fill(colorFondo)
                            .ignoresSafeArea()
                        // Área interactiva que cubre toda la vista
                        ZoomableScrollView(
                            currentScale: $currentScale,
                            finalScale: $finalScale,
                            currentPosition: $currentPosition,
                            minScale: minScale,
                            maxScale: maxScale,
                            containerSize: geometry.size
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(colorFondo)
                                    .padding(7.5)
                                
                                interactiveMapView(svgName: svgName, idZona: idZona)
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                    .rotationEffect(.degrees(180))
                                    .frame(maxWidth: UIScreen.screenWidth/1.1, maxHeight: UIScreen.screenHeight/1.1)
                                    .offset(y: -UIScreen.screenHeight/4)
                                    .background(colorFondo)
                                    .scaleEffect(1)
                            }
                            .scaleEffect(0.9)
                            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                        }
                    }
                    .background(Color.white)
                    .ignoresSafeArea()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func interactiveMapView(svgName: String, idZona: Int) -> some View {
        // Variables para los offsets
        var offX: CGFloat = 0
        var offY: CGFloat = 0
        
        // Asignación de valores a offX y offY según idZona
        switch idZona {
        case 1:
            offX = 10
            offY = 20
        case 2:
            offX = 15
            offY = -220
        case 3:
            offX = 0
            offY = -160
        case 4:
            offX = 0
            offY = 0
        case 5:
            offX = 25
            offY = -210
        case 6:
            offX = 18
            offY = -88
        default:
            offX = 0
            offY = 0 // Valores por defecto si no coincide con ningún caso
        }
        
        return InteractiveMap(svgName: svgName) { pathData in
            InteractiveShape(pathData)
                .stroke(clickedPath == pathData ? pathDictionary[pathData.name]?.0 ?? Color.white.opacity(0.4) : pathDictionary[pathData.name]?.0 ?? Color.white.opacity(1))
                .background(InteractiveShape(pathData).fill(pathDictionary[pathData.name]?.0 ?? Color.white))
                .onTapGesture {
                    clickedPath = pathData
                    if(clickedPath.name != "undefined"){
                        print(clickedPath.name)
                        onSelectPath(clickedPath.name)
                        dismiss()
                    }
                }
        }
        .id(svgName)
        .offset(x: offX, y: offY) // Aplicar el offset basado en idZona
    }
}

struct ZoomableScrollView<Content: View>: View {
    @Binding var currentScale: CGFloat
    @Binding var finalScale: CGFloat
    @Binding var currentPosition: CGSize
    let minScale: CGFloat
    let maxScale: CGFloat
    let content: Content
    let containerSize: CGSize
    
    @GestureState private var magnifyBy: CGFloat = 1.0
    @State private var steadyStateZoom: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    @State private var steadyStatePosition: CGSize = .zero
    
    @State private var shouldCenter: Bool = false
    private let marginFraction: CGFloat = 0.1
    
    init(currentScale: Binding<CGFloat>,
         finalScale: Binding<CGFloat>,
         currentPosition: Binding<CGSize>,
         minScale: CGFloat,
         maxScale: CGFloat,
         containerSize: CGSize,
         @ViewBuilder content: () -> Content) {
        _currentScale = currentScale
        _finalScale = finalScale
        _currentPosition = currentPosition
        self.minScale = minScale
        self.maxScale = maxScale
        self.containerSize = containerSize
        self.content = content()
    }
    
    private func getBounds() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let margin = containerSize.width * marginFraction
        let verticalMargin = containerSize.height * marginFraction
        
        let effectiveWidth = containerSize.width * (currentScale - 1) / 2
        let effectiveHeight = containerSize.height * (currentScale - 1) / 2
        
        return (
            -effectiveWidth - margin,
             effectiveWidth + margin,
             -effectiveHeight - verticalMargin,
             effectiveHeight + verticalMargin
        )
    }
    
    private func constrainPosition(_ position: CGSize) -> CGSize {
        let (minX, maxX, minY, maxY) = getBounds()
        
        return CGSize(
            width: min(maxX, max(minX, position.width)),
            height: min(maxY, max(minY, position.height))
        )
    }
    
    private func centerContent() {
        withAnimation(.spring()) {
            currentPosition = .zero
            steadyStatePosition = .zero
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .scaleEffect(currentScale)
                .offset(x: currentPosition.width + dragOffset.width,
                        y: currentPosition.height + dragOffset.height)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .updating($magnifyBy) { value, state, _ in
                                state = value
                            }
                            .onChanged { value in
                                let newScale = steadyStateZoom * value
                                currentScale = min(max(newScale, minScale), maxScale)
                                currentPosition = constrainPosition(currentPosition)
                                
                                if currentScale <= minScale {
                                    shouldCenter = true
                                }
                            }
                            .onEnded { value in
                                steadyStateZoom = min(max(steadyStateZoom * value, minScale), maxScale)
                                finalScale = steadyStateZoom
                                currentScale = steadyStateZoom
                                
                                if currentScale <= minScale && shouldCenter {
                                    centerContent()
                                    shouldCenter = false
                                } else {
                                    currentPosition = constrainPosition(currentPosition)
                                    steadyStatePosition = currentPosition
                                }
                            },
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                // Only allow dragging if not at minimum scale
                                if currentScale > minScale {
                                    let newPosition = CGSize(
                                        width: steadyStatePosition.width + value.translation.width,
                                        height: steadyStatePosition.height + value.translation.height
                                    )
                                    let constrainedPosition = constrainPosition(newPosition)
                                    state = CGSize(
                                        width: constrainedPosition.width - steadyStatePosition.width,
                                        height: constrainedPosition.height - steadyStatePosition.height
                                    )
                                }
                            }
                            .onEnded { value in
                                // Only update position if not at minimum scale
                                if currentScale > minScale {
                                    let newPosition = CGSize(
                                        width: steadyStatePosition.width + value.translation.width,
                                        height: steadyStatePosition.height + value.translation.height
                                    )
                                    currentPosition = constrainPosition(newPosition)
                                    steadyStatePosition = currentPosition
                                }
                            }
                    )
                )
        }
    }
}

#Preview {
    MapaDetalladoZona { id in
        print("Selected path ID: \(id)")
    }
}
