//
// vistaEventos.swift
// proyectoReto
//
// Created by Pedr1p on 05/11/24.
//

import SwiftUI

struct vistaEventos: View {
    @StateObject private var service = EventosService()
    @Environment(\.presentationMode) var presentationMode // Ambiente para controlar la navegación

    var body: some View {
        VStack {
            Form {
                ForEach(service.eventos) { evento in
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(evento.Titulo)
                                .font(.headline)
                            Text(evento.Descripcion)
                                .font(.subheadline)
                            Text("Fecha de inicio: \(evento.FechaInicio)")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            Text("Fecha de Finalización: \(evento.FechaFinal)")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            
                            AsyncImage(url: URL(string: evento.ImagenLink)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .onAppear {
                service.fetchEventos()
            }
        }
        .padding()
        .navigationBarTitle("Eventos", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Esconde el botón de retroceso predeterminado
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss() // Cierra la vista y regresa
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
                .foregroundColor(.blue)
        })
    }
}

#Preview {
    vistaEventos()
}

