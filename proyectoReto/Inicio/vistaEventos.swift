//
//  vistaEventos.swift
//  proyectoReto
//
//  Created by Pedr1p on 05/11/24.
//

import SwiftUI

let listaEventos = ["Evento1", "Evento2", "Evento3"]

struct vistaEventos: View {
    var body: some View {
        VStack {
            Text("Eventos")
                .font(.largeTitle)
                .bold()
            Form {
                ForEach(listaEventos, id: \.self) { evento in
                    Section() {
                        Text(evento)
                        Image("papalotl")
                            .frame(width: 500, height: 100)
                    }
                    
                }
            }
        }
        }
    }


#Preview {
    vistaEventos()
}
