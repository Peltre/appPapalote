import SwiftUI

struct TemplateActividad2: View {
    var unaActividad: Actividad2
    var qrFlag: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var isActivityCompleted = false
    @State private var showPopup = false // State to control popup visibility
    @State private var newInsignias: [Insignia] = [] // Store new insignias to show in the popup

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                GeometryReader { geometry in
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(
                                stops: [
                                    .init(color: colores[unaActividad.idZona]!.opacity(0.6), location: 0),
                                    .init(color: colores[unaActividad.idZona]!.opacity(0.4), location: 1)
                                ]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .mask(LinearGradient(
                            gradient: Gradient(
                                stops: [.init(color: .black, location: 0.4),
                                        .init(color: .black.opacity(0), location: 0.8)]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 1200)
                }
                .edgesIgnoringSafeArea(.all)

                // Main content
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        // Back button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25)
                                .foregroundColor(.black)
                                .bold()
                                .padding(10)
                                .background(Color(white: 1))
                                .clipShape(Circle())
                        }
                        .zIndex(2)

                        VStack(spacing: 20) {
                            // Header
                            Text(unaActividad.nombre)
                                .padding()
                                .bold()
                                .font(.largeTitle)
                                .foregroundColor(colores[unaActividad.idZona]!)

                            if qrFlag && unaActividad.completar {
                                // Complete button
                                Button(action: {
                                    ActividadUsuario.crearActividadUsuarioLocal(idUsuario: usuarioGlobal!.idUsuario, idActividad: unaActividad.idActividad) { success in
                                        if success {
                                            print("Actividad creada exitosamente.")
                                            actividadesCompletadas[unaActividad.idActividad] = true
                                            isActivityCompleted = true

                                            // After creating the activity, verify insignias
                                            if let newInsignias = VerificadorInsignias.shared.verificarInsignias(), !newInsignias.isEmpty {
                                                // Store new insignias and show the popup
                                                self.newInsignias = newInsignias
                                                showPopup = true
                                            }
                                        } else {
                                            print("Error al crear la actividad.")
                                        }
                                    }
                                }) {
                                    Text(actividadesCompletadas[unaActividad.idActividad] ? "Completada" : "Completar")
                                        .foregroundColor(actividadesCompletadas[unaActividad.idActividad] ? .red : .green)
                                        .padding(5)
                                        .background(Color.white)
                                        .cornerRadius(5)
                                }
                                .disabled(isActivityCompleted)
                            }

                            // Cards
                            ForEach(unaActividad.listaTarjetas, id: \.idTarjeta) { tarjeta in
                                tarjetaView(tarjeta: tarjeta, actividad: unaActividad)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    }
                }
            }
            .onAppear {
                isActivityCompleted = actividadesCompletadas[unaActividad.idActividad]
            }
            .navigationBarBackButtonHidden(true)

            // Show the Popup when `showPopup` is true
            if showPopup {
                PopupInsigniasView(showPopup: $showPopup, nuevasInsignias: newInsignias)
                    .zIndex(1) // Ensure the popup appears on top
            }
        }
    }

    func tarjetaView(tarjeta: Tarjeta, actividad: Actividad2) -> some View {
        let cardWidth: CGFloat = UIScreen.screenWidth - 50

        let question: Question?
        if let texto = tarjeta.texto, let data = texto.data(using: .utf8) {
            let decoder = JSONDecoder()
            question = try? decoder.decode(Question.self, from: data)
        } else {
            question = nil
        }

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
                .frame(width: cardWidth)
            )
        case 2, 3:
            if let question = question {
                return AnyView(
                    SlidingOverlayCardView(question: question)
                        .frame(width: cardWidth, height: cardWidth)
                )
            } else {
                return AnyView(
                    Text("Invalid JSON format for question")
                        .foregroundColor(.red)
                )
            }
        case 4:
            return AnyView(
                ZStack {
                    Circle()
                        .fill(colores[actividad.idZona]!)
                        .frame(width: cardWidth, height: cardWidth)

                    if let imagenUrl = tarjeta.imagenUrl, let url = URL(string: imagenUrl) {
                        CacheAsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: cardWidth, height: cardWidth)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: cardWidth - 20, height: cardWidth - 20)
                            case .failure(let error):
                                Text("Error loading image: \(error)")
                                    .frame(width: cardWidth, height: cardWidth)
                            @unknown default:
                                fatalError()
                            }
                        }
                    }
                }
                .frame(width: cardWidth, height: cardWidth)
                .padding(.vertical, 20)
            )
        default:
            return AnyView(EmptyView())
        }
    }
}

// Create a separate view for individual insignia
struct InsigniaItemView: View {
    let insignia: Insignia
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: insignia.ImagenLink)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } placeholder: {
                ProgressView()
            }
            Text(insignia.Nombre)
                .font(.caption)
        }
        .padding(.horizontal, UIScreen.screenWidth/3.45)
    }
}

// Create a separate view for the insignias list
struct InsigniasListView: View {
    let insignias: [Insignia]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(insignias, id: \.InsigniaId) { insignia in
                    InsigniaItemView(insignia: insignia)
                }
            }
            .padding()
        }
    }
}

// Main popup view
struct PopupInsigniasView: View {
    @Binding var showPopup: Bool
    let nuevasInsignias: [Insignia]

    var body: some View {
        VStack {
            // Header
            Text("Nuevas Insignias Completadas")
                .font(.headline)
                .padding(.top, 20)
            
            // Insignias list
            InsigniasListView(insignias: nuevasInsignias)
            
            // Close button
            Button(action: {
                withAnimation {
                    showPopup = false
                }
            }) {
                Text("Cerrar")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .background(.ultraThinMaterial.opacity(0.6))
        .cornerRadius(30)
        .padding()
        .transition(.move(edge: .top))
        .animation(.easeInOut(duration: 0.3), value: showPopup)
    }
}

#Preview {
    TemplateActividad2(unaActividad: Actividad2(idActividad: 3, idZona: 2, nombre: "PEPE", listaTarjetas: Tarjeta.datosEjemplo, completar: true), qrFlag: true)
}

//#Preview {
//    struct PreviewWrapper: View {
//        @State var showPopup: Bool = true
//        
//        let sampleInsignias: [Insignia] = [
//            Insignia(
//                InsigniaId: 1,
//                ImagenLink: "https://cdn-icons-png.flaticon.com/512/411/411728.png",
//                Nombre: "Insignia Explorador",
//                Descripcion: "Otorgada por explorar nuevas áreas",
//                Valor: 100
//            ),
//            Insignia(
//                InsigniaId: 2,
//                ImagenLink: "https://cdn-icons-png.flaticon.com/512/411/411728.png",
//                Nombre: "Insignia Aventurero",
//                Descripcion: "Completar 5 actividades",
//                Valor: 200
//            ),
//            Insignia(
//                InsigniaId: 3,
//                ImagenLink: "https://cdn-icons-png.flaticon.com/512/411/411728.png",
//                Nombre: "Insignia Experto",
//                Descripcion: "Dominar todas las zonas",
//                Valor: 300
//            ),
//            Insignia(
//                InsigniaId: 4,
//                ImagenLink: "https://cdn-icons-png.flaticon.com/512/411/411728.png",
//                Nombre: "Insignia Maestro",
//                Descripcion: "Dominar todas las zonas",
//                Valor: 300
//            )
//        ]
//        
//        var body: some View {
//            ZStack {
//                Color.gray.opacity(0.3) // Background to show the popup better
//                PopupInsigniasView(showPopup: $showPopup, nuevasInsignias: sampleInsignias)
//            }
//        }
//    }
//    
//    return PreviewWrapper()
//}
