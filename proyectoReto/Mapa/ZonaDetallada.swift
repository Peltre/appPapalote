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
                
                VStack {
                    // Back button and title
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
                        }
                        .offset(x: -UIScreen.screenWidth / 2 + 35)
                        
                        Text(pathDictionary[TituloZona]?.1 ?? "Rara")
                            .font(.system(size: 35))
                            .bold()
                    }
                    
                    ScrollView {
                        VStack {
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        // Store the total scrollable height once it appears
                                        scrollViewHeight = geometry.size.height
                                    }
                            }
                            .frame(height: 0) // Hidden, used only for size reference
                            
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
                                    .frame(width: UIScreen.screenWidth * 0.8, height: 500) // Flexible width, fixed height
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                            .padding(.top, 110)
                            .padding(.bottom, 20)
                        }
                    }
                    .content.offset(y: -scrollViewOffset) // Apply calculated offset
                    
                    NavigationLink(destination: MapaDetalladoZona(onSelectPath: { selectedNombre in
                        enfocarActividadNombre = selectedNombre
                        print("Zona \(String(describing: enfocarActividadNombre))")
                        // Call scrollToActivityWithPercentage with selectedNombre
                        scrollToActivityWithPercentage(selectedNombre: selectedNombre)
                    }, idZona: idZona)) {
                        Text("Mapa Detallado")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 220)
                            .background(colores[idZona] ?? Color.gray)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                    .padding(.top, 15)
                    .background(.red)
                }
                .navigationBarBackButtonHidden(true)
                .background(.thinMaterial.opacity(0.8))
            }
        }
    }
    
    private func scrollToActivityWithPercentage(selectedNombre: String) {
        
        // Normalize the target name for comparison
        let normalizedTargetName = normalizeString(selectedNombre)
        print("Normalized target name to find: \(normalizedTargetName)")

        // Iterate and print each comparison for debugging
        if let targetIndex = actividadModel.actividadesFiltradas.firstIndex(where: { actividad in
            let normalizedActividadNombre = normalizeString(actividad.nombre)
            print("Comparing with activity name: \(actividad.nombre) -> normalized: \(normalizedActividadNombre)")
            return normalizedActividadNombre == normalizedTargetName
        }) {
            let totalItems = actividadModel.actividadesFiltradas.count
            let scrollPercentage = CGFloat(targetIndex) / CGFloat(totalItems - 1)
            
            // Calculate and set the scroll offset based on the percentage of the total scrollable height
            scrollViewOffset = scrollViewHeight * scrollPercentage
            print("Found match at index \(targetIndex), scroll percentage: \(scrollPercentage), offset: \(scrollViewOffset)")
        } else {
            print("No match found for activity name: \(normalizedTargetName)")
        }
    }
}

#Preview {
    ZonaDetallada(TituloZona: "Pertenezco", idZona: 2)
}
