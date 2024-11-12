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
            ZStack{
                colores[idZona]!
                    .ignoresSafeArea()
                ScrollViewReader { proxy in
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
                            .offset(x: -UIScreen.main.bounds.width/2 + 35)
                            Text(pathDictionary[TituloZona]?.1 ?? "Rara")
                                .font(.system(size: 35))
                                .bold()
                        }
                        
                        // Lista de actividades con fondo de color
                        ZStack {
                            (pathDictionary[TituloZona]?.0 ?? Color(white: 0.75))
                                .edgesIgnoringSafeArea(.all)
                            
                            List(actividadModel.actividadesFiltradas) { actividad in
                                NavigationLink(destination: TemplateActividad2(unaActividad: actividad)
                                    .onDisappear {
                                        enfocarActividadNombre = nil // Restablece a nil cuando se regresa de TemplateActividad2
                                    }
                                ) {
                                    CeldaJugador(
                                        unaActividad: actividad,
                                        idZona: idZona,
                                        isHighlighted: actividad.nombre.removeAccents() == enfocarActividadNombre
                                    )
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                }
                                .id(actividad.idActividad) // Asigna el ID de cada celda
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(PlainListStyle())
                            .offset(x: 9)
                            
                        }
                        .shadow(radius: 5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
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
                        .padding(.top,15)
                        
                    }
                    .navigationBarBackButtonHidden(true)
                    .onAppear {
                        if let nombre = enfocarActividadNombre?.removeAccents() {
                            actividadModel.actividadesFiltradas.forEach { actividad in
                                print("Comparing: \(nombre) - \(actividad.nombre.removeAccents())")
                            }
                            
                            if let actividad = actividadModel.actividadesFiltradas.first(where: { $0.nombre.removeAccents().caseInsensitiveCompare(nombre) == .orderedSame }) {
                                // Desplaza al elemento con el ID correspondiente al nombre
                                proxy.scrollTo(actividad.idActividad, anchor: .center)
                            }
                        }
                    }
                    .background(.thinMaterial.opacity(0.8))
                    
                }
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
