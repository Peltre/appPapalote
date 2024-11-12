import SwiftUI
import InteractiveMap

struct ContentViewMapas: View {
    @State private var clickedPath = PathData()
    @State private var svgName = "Piso1" // Default SVG name
    @State private var opacity: Double = 1 // State for controlling opacity
    @State private var tituloPiso: String = "Piso 1" // Initial title
    @State private var selectedZona: ZonaDetallada? // Variable para la vista seleccionada
    @Environment(\.presentationMode) var presentationMode // Para controlar la presentación
    
    var body: some View {
        NavigationStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss() // Cierra la vista actual
            }) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 20))
                    .frame(width: 25)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color(white: 1))
                    .clipShape(Circle())
            }
            .offset(x: -UIScreen.screenWidth / 2 + 35)
            
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        clickedPath = PathData() // Reset clickedPath to its initial state
                    }
                
                VStack {
                    Text(tituloPiso)
                        .font(.system(size: 40, weight: .black))
                    interactiveMapView(svgName: svgName)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 157)
                .opacity(opacity)
            }
            .fullScreenCover(item: $selectedZona) { zonaDetallada in
                zonaDetallada // Presenta la vista ZonaDetallada
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func interactiveMapView(svgName: String) -> some View {
        InteractiveMap(svgName: svgName) { pathData in
            InteractiveShape(pathData)
                .stroke(clickedPath == pathData ? pathDictionary[pathData.name]?.0 ?? Color(white: 0.75) : pathDictionary[pathData.name]?.0 ?? Color(white: 0.75))
                .background(InteractiveShape(pathData).fill(pathDictionary[pathData.name]?.0 ?? Color(white: 0.75)))
                .onTapGesture {
                    clickedPath = pathData
                    if clickedPath.name == "Path 30" || clickedPath.name == "Path 25" {
                        let newSvgName = clickedPath.name == "Path 30" ? "Piso1" : "Piso2"
                        fadeTransition(to: newSvgName, title: clickedPath.name == "Path 30" ? "Piso 1" : "Piso 2")
                    } else {
                        // Determina el ID de la zona basado en el nombre del Path
                        let idZona: Int
                        switch clickedPath.name {
                        case "Path 21":
                            idZona = 1 // Expreso
                        case "Path 22":
                            idZona = 5 // Soy
                        case "Path 23":
                            idZona = 6 // Pequeños
                        case "Path 31":
                            idZona = 4 // Comprendo
                        case "Path 26":
                            idZona = 3 // Pertenezco
                        case "Path 27":
                            idZona = 2 // Comunico
                        case "Path 28":
                            idZona = 6 // Pequeños
                        default:
                            idZona = 0
                        }
                        
                        // Asigna la vista seleccionada a selectedZona
                        selectedZona = ZonaDetallada(TituloZona: String(clickedPath.name), idZona: idZona)
                    }
                    print("\(self.clickedPath.name)")
                }
                .animation(.easeInOut(duration: 0.3), value: clickedPath)
        }
        .id(svgName)
    }
    
    private func fadeTransition(to newSvgName: String, title: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            opacity = 0 // Fade out
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            svgName = newSvgName // Change SVG
            tituloPiso = title // Change the title after fading out
            withAnimation(.easeInOut(duration: 0.3)) {
                opacity = 1 // Fade in
            }
        }
    }
}

#Preview {
    ContentViewMapas()
}

