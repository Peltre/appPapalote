//
//  vistaEventos.swift
//  proyectoReto
//
//  Created by Pedr1p on 05/11/24.
//

import SwiftUI


struct vistaEventos: View {
    
    @StateObject private var service = EventosService()
    
    var body: some View {
        VStack {
            Text("Eventos")
                .font(.largeTitle)
                .bold()
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
                            Text("Fecha de Finalizacion: \(evento.FechaFinal)")
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
    }
}


#Preview {
    vistaEventos()
}
