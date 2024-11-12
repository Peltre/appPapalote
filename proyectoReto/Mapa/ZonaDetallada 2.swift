//
//  ZonaDetallada 2.swift
//  proyectoReto
//
//  Created by Carlos Eugenio Saldaña Tijerina on 17/10/24.
//


import SwiftUI

struct ZonaDetallada: View {
    var TituloZona: String
    var idZona: Int
    
    @Environment(\.dismiss) private var dismiss
    
    // Filtrar las actividades por la zona seleccionada
    var actividadesFiltradas: [Actividad] {
        Actividad.datosEjemplo.filter { $0.id_zona == idZona }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Botón de retroceso y título
                HStack {
                    Button(action: {
                        dismiss() // Cierra la vista actual
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color(white: 0.85))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Lista de actividades con fondo de color
                ZStack {
                    (pathDictionary[TituloZona]?.0 ?? Color(white: 0.75))
                        .edgesIgnoringSafeArea(.all)
                    
                    List(actividadesFiltradas) { actividad in
                        NavigationLink(destination: TemplateActividad(unaActividad: actividad)) {
                            CeldaJugador(unaActividad: actividad)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.8)) // Fondo más claro para mejor legibilidad
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .padding(.horizontal)
                        }
                        .listRowBackground(Color.clear) // Hace el fondo de la lista transparente
                    }
                    .listStyle(PlainListStyle()) // Estilo limpio para la lista
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(pathDictionary[TituloZona]?.1 ?? "Rara") // Título de la zona
        }
    }
}