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

                            if qrFlag && (unaActividad.completar != 0) {
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
                                        .foregroundColor(actividadesCompletadas[unaActividad.idActividad] ? .black : .white)
                                        .bold()
                                        .padding(5)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 7)
                                        .background(actividadesCompletadas[unaActividad.idActividad] ? .red : .green)
                                        .cornerRadius(20)
                                        .shadow(radius: 5, y: 2)
                                        .animation(.easeInOut(duration: 0.3), value: actividadesCompletadas[unaActividad.idActividad]) // Apply animation here
                                }
                                .padding(.bottom,20)
                                .scaleEffect(1.3)
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
                            .fill(.thinMaterial)
                            .shadow(color: Color(white: 0.96), radius: 2)
                        
                        VStack(spacing: 20) {
                            Spacer()
                            Text(question?.titulo ?? "")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text(question?.texto ?? "")
                                .font(.body)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .fixedSize(horizontal: false, vertical: true) // Asegura que el texto se expanda
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(width: cardWidth)
                    .frame(minHeight: 180) // Altura mínima
                    .background(GeometryReader { geometry in
                        Color.clear.onAppear {
                            print("Height: \(geometry.size.height)") // Para debugging, si lo necesitas
                        }
                    })
                )
            case 2, 3:
                if let question = question {
                    return AnyView(
                        SlidingOverlayCardView(question: question, imageUrl: tarjeta.imagenUrl)
                            .frame(width: cardWidth, height: cardWidth)
                    )
                } else {
                    return AnyView(
                        Text("Invalid JSON format for question")
                            .foregroundColor(.red)
                    )
                }
            case 5:
                return AnyView(
                    QuizCardView(question: question, cardWidth: cardWidth)
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
            if let url = URL(string: insignia.ImagenLink) {
                CacheAsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .shadow(radius: 4)
                    case .failure:
                        Image(systemName: "medalla")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "medalla")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            Text(insignia.Nombre)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, UIScreen.screenWidth/3.85)
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
    TemplateActividad2(unaActividad: Actividad2(idActividad: 3, idZona: 2, nombre: "PEPE", listaTarjetas: Tarjeta.datosEjemplo, completar: 1), qrFlag: true)
}

struct QuizCardView: View {
    let question: Question?
    let cardWidth: CGFloat
    @State private var selectedAnswer: Int?
    
    private func verifyAnswer(buttonNumber: Int) -> Bool {
        if let correctString = question?.correcta {
            let expectedAnswer = "respuesta\(buttonNumber)"
            return correctString == expectedAnswer
        }
        return false
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.7))
                .frame(minWidth: cardWidth, minHeight: 300)
                .shadow(color: Color(white: 0.96), radius: 2)
            
            VStack(spacing: 20) {
                Text(question?.titulo ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(question?.texto ?? "")
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        QuizButton(
                            text: question?.respuesta1 ?? "",
                            isSelected: selectedAnswer == 1,
                            isCorrect: selectedAnswer == 1 ? verifyAnswer(buttonNumber: 1) : false,
                            action: { selectedAnswer = 1 }
                        )
                        
                        QuizButton(
                            text: question?.respuesta2 ?? "",
                            isSelected: selectedAnswer == 2,
                            isCorrect: selectedAnswer == 2 ? verifyAnswer(buttonNumber: 2) : false,
                            action: { selectedAnswer = 2 }
                        )
                    }
                    
                    HStack(spacing: 15) {
                        QuizButton(
                            text: question?.respuesta3 ?? "",
                            isSelected: selectedAnswer == 3,
                            isCorrect: selectedAnswer == 3 ? verifyAnswer(buttonNumber: 3) : false,
                            action: { selectedAnswer = 3 }
                        )
                        
                        QuizButton(
                            text: question?.respuesta4 ?? "",
                            isSelected: selectedAnswer == 4,
                            isCorrect: selectedAnswer == 4 ? verifyAnswer(buttonNumber: 4) : false,
                            action: { selectedAnswer = 4 }
                        )
                    }
                }
                .padding()
            }
            .padding()
        }
        .frame(width: cardWidth)
    }
}

struct QuizButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.body)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ?
                                (isCorrect ? Color.green : Color.red) :
                                Color.clear,
                            lineWidth: isSelected ? 3 : 0
                        )
                        .shadow(
                            color: isSelected ?
                                (isCorrect ? Color.green : Color.red) :
                                Color.clear,
                            radius: 5
                        )
                )
        }
    }
}
