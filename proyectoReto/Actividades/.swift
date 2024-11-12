//
//  ListaActividades 2.swift
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

struct ListaActividades2: View {
    let datosEjemplo = Actividad.datosEjemplo
    var body: some View {
        NavigationStack {
            List(datosEjemplo) { actividad in
                NavigationLink {
                    TemplateActividad(unaActividad: actividad)
                } label: {
                    CeldaJugador(unaActividad: actividad)
                }
            }
            .navigationTitle("Actividades")
        }
    }
}

struct CeldaJugador2: View {
    var unaActividad : Actividad
    var body: some View {
        HStack {
            Image(systemName: "balloon.2.fill")
                .resizable()
                .foregroundStyle(.tint)
                .aspectRatio(contentMode: .fit)
                .frame(width: 15)
            VStack (alignment: .leading){
                Text(unaActividad.nombre)
                    .font(.title2)
            }
        }
    }
}


#Preview {
    ListaActividades()
}
