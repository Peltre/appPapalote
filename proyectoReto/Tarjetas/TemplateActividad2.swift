//
//  vistaPertenezco.swift
//  proyectoReto
//
//  Created by Dodi on 13/10/24.
//

import SwiftUI

struct TemplateActividad2: View {
    var unaActividad: Actividad2
    @Environment(\.dismiss) private var dismiss
    @State private var isActivityCompleted = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Back button
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
                .offset(x: -UIScreen.main.bounds.width / 2 + 35, y: -UIScreen.screenHeight / 2 + 60)
                .zIndex(2)
                
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
                    VStack(spacing: 20) {
                        // Header
                        Text(unaActividad.nombre)
                            .padding()
                            .bold()
                            .font(.largeTitle)
                            .foregroundColor(colores[unaActividad.idZona]!)
                        
                        // Complete button
                        Button(action: {
                            ActividadUsuario.crearActividadUsuario(idUsuario: usuarioGlobal!.idUsuario, idActividad: unaActividad.idActividad) { success in
                                if success {
                                    print("Actividad creada exitosamente.")
                                    actividadesCompletadas[unaActividad.idActividad] = true
                                    isActivityCompleted = true
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
                        
                        // Cards
                        ForEach(unaActividad.listaTarjetas, id: \.idTarjeta) { tarjeta in
                            tarjetaView(tarjeta: tarjeta, actividad: unaActividad)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                isActivityCompleted = actividadesCompletadas[unaActividad.idActividad]
            }
            .navigationBarBackButtonHidden(true)
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


#Preview {
    TemplateActividad2(unaActividad: Actividad2(idActividad: 3, idZona: 2, nombre: "PEPE", listaTarjetas: Tarjeta.datosEjemplo))
}
