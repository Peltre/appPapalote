//
//  ListaActividades.swift
//  proyectoReto
//
//  Created by Carlos Eugenio Saldaña Tijerina on 17/10/24.
//


//
//  ListaActividades.swift
//  ViewActividadPapalote
//
//  Created by Alumno on 15/10/24.
//

import SwiftUI

struct ListaActividades: View {
    let actividades: [Actividad2]
    
    var body: some View {
        NavigationStack {
            List(actividades) { actividad in
                NavigationLink {
                    TemplateActividad2(unaActividad: actividad)
                } label: {
                    CeldaJugador(unaActividad: actividad, idZona: 0, isHighlighted: false)
                }
            }
            .navigationTitle("Actividades")
        }
    }
}




