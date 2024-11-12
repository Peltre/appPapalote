import SwiftUI

struct ZonaDetallada: View, Identifiable {
    var id: UUID = UUID() // Identificador único
    @State var TituloZona: String
    var idZona: Int
    @State var enfocarActividadNombre: String? // Nombre de actividad a enfocar
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var actividadModel: ActividadesViewModel
    
    init(TituloZona: String, idZona: Int) {
        self.TituloZona = TituloZona
        self.idZona = idZona
        _actividadModel = StateObject(wrappedValue: ActividadesViewModel(idZona: idZona))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                colores[idZona]!
                    .ignoresSafeArea()
                
                VStack {
                    // Botón de retroceso y título
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
                    
                    // Scrollable card stack for actividades using CacheAsyncImage
                    // Scrollable card stack for actividades
                    ScrollableCardStack(data: actividadModel.actividadesFiltradas) { actividad in
                        NavigationLink(destination: TemplateActividad2(unaActividad: actividad)) {
                            ZStack {
                                // Find tarjeta with orden_lista == 1
                                if let backgroundImageUrl = actividad.listaTarjetas.first(where: { $0.ordenLista == 1 })?.imagenUrl {
                                    AsyncImage(url: URL(string: backgroundImageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3) // Placeholder while loading
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.black.opacity(0.4)) // Apply ultra-thin material overlay for more diffused look
                                    )
                                }

                                VStack {
                                    Text("\(actividad.idActividad)")
                                        .font(.largeTitle)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text(actividad.nombre)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: UIScreen.screenWidth-60, height: UIScreen.screenHeight/1.7) // Set size to match demo card height
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    .padding(.top, 90)
                    
                    Spacer()
                    
                    // Footer con botón "Ir a la vista de mapa"
                    NavigationLink(destination: MapaDetalladoZona(onSelectPath:  { selectedNombre in
                        enfocarActividadNombre = selectedNombre.capitalized
                    }, idZona: idZona)) {
                        Text("Ir a la vista de mapa")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 220)
                            .background(colores[idZona] ?? Color.gray)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                    .padding(.top, 15)
                }
                .navigationBarBackButtonHidden(true)
                .background(.thinMaterial.opacity(0.8))
            }
        }
    }
}



struct CeldaJugador: View {
    var unaActividad: Actividad2
    var idZona: Int
    var isHighlighted: Bool // Propiedad para determinar si se debe resaltar
    
    var body: some View {
        HStack {
            Text("\(unaActividad.idActividad)")
                .font(.system(size: 30))
                .foregroundStyle(colores[idZona]!)
                .frame(width: 45)
                .padding(4)
                .background(Color(white: 1))
                .clipShape(Circle())
                .offset(x: 4)
            Spacer()
            Text(unaActividad.nombre)
                .font(.system(size: 26))
                .foregroundColor(.black)
                .offset(x: UIScreen.screenWidth/10 - 65)
            Spacer()
        }
        .padding(.vertical, 20)
        .frame(width: UIScreen.screenWidth-40)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerSize: CGSize(width: 18, height: 5)))
        .overlay(
            isHighlighted ? RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 4) // Borde iluminado
            : nil
        )
    }
}

#Preview {
    ZonaDetallada(TituloZona: "Pertenezco", idZona: 2)
}
