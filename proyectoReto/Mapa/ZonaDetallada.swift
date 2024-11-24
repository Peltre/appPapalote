import SwiftUI
struct ZonaDetallada: View, Identifiable {
    var id: UUID = UUID()
    @State var TituloZona: String
    var idZona: Int
    @State var enfocarActividadNombre: String?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var actividadModel: ActividadesViewModel
    
    @State private var scrollViewOffset: CGFloat = 0  // Track offset
    @State private var scrollViewHeight: CGFloat = 0  // Store total scrollable height
    
    init(TituloZona: String, idZona: Int, enfocarActividadNombre: String? = nil) {
        self.TituloZona = TituloZona
        self.idZona = idZona
        self._actividadModel = StateObject(wrappedValue: ActividadesViewModel(idZona: idZona))
        self._enfocarActividadNombre = State(initialValue: enfocarActividadNombre)
    }
    
    private func normalizeString(_ string: String) -> String {
        return string.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colores[idZona]!
                    .ignoresSafeArea()
                
                Rectangle()
                    .fill(.thinMaterial).opacity(0.6)
                    .frame(width: UIScreen.screenWidth, height: 200)
                    .offset(y: -UIScreen.screenHeight/2 + 16)
                    .shadow(radius: 10)
                
                Rectangle()
                    .fill(.thinMaterial).opacity(0.6)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight/5)
                    .offset(y: UIScreen.screenHeight/2.23)
                    .shadow(radius: 10, y: -5)
                
                
                
                ScrollViewReader { scrollProxy in
                    ScrollableCardStack(data: actividadModel.actividadesFiltradas) { actividad in
                        NavigationLink(destination: TemplateActividad2(unaActividad: actividad)) {
                            ZStack {
                                if let backgroundImageUrl = actividad.listaTarjetas.first(where: { $0.ordenLista == 1 })?.imagenUrl {
                                    AsyncImage(url: URL(string: backgroundImageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.black.opacity(0.6))
                                    )
                                }
                                VStack {
                                    Text("\(actividad.idActividad)")
                                        .font(.system(size: 45))
                                        .bold()
                                        .foregroundColor(.white)
                                    Text(actividad.nombre)
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: UIScreen.screenWidth)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .scaleEffect(0.85)
                        }
                        .id(actividad.idActividad) // Assign an ID based on activity
                    }
                    .onChange(of: enfocarActividadNombre) { newValue in
                        if let newValue = newValue {
                            scrollToActivity(scrollProxy: scrollProxy, selectedNombre: newValue)
                        }
                    }
                }
                .ignoresSafeArea()
                
                ZStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color(white: 1))
                            .clipShape(Circle())
                            .shadow(radius: 3, y: 2)
                    }
                    .offset(x: -UIScreen.screenWidth / 2 + 35)
                    
                    Text(pathDictionary[TituloZona]?.1 ?? "Rara")
                        .font(.system(size: 35))
                        .bold()
                }
                .padding(.bottom, UIScreen.screenHeight/1.2)
                
                NavigationLink(destination: MapaDetalladoZona(onSelectPath: { selectedNombre in
                    enfocarActividadNombre = selectedNombre
                    print("Zona \(String(describing: enfocarActividadNombre))")
                }, idZona: idZona)) {
                    Text("Mapa Detallado")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 60)
                        .background(.ultraThinMaterial).opacity(0.7)
                        .cornerRadius(30)
                        .shadow(radius: 5, y: 3)
                }
                .padding(.top, UIScreen.screenHeight/1.2)
                
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    private func scrollToActivity(scrollProxy: ScrollViewProxy, selectedNombre: String) {
        // Normalize the target name for comparison
        let normalizedTargetName = normalizeString(selectedNombre)
        print("Normalized target name to find: \(normalizedTargetName)")
        // Find the matching activity
        if let targetActividad = actividadModel.actividadesFiltradas.first(where: { actividad in
            let normalizedActividadNombre = normalizeString(actividad.nombre)
            return normalizedActividadNombre == normalizedTargetName
        }) {
            print("Scrolling to activity with ID: \(targetActividad.idActividad)")
            // Scroll to the activity ID with animation
            withAnimation(.easeInOut) {
                scrollProxy.scrollTo(targetActividad.idActividad, anchor: .center)
            }
        } else {
            print("No match found for activity name: \(normalizedTargetName)")
        }
    }
}
#Preview {
    ZonaDetallada(TituloZona: "Pertenezco", idZona: 2)
}

