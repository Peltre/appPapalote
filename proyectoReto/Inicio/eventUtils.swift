//
//  eventUtils.swift
//  proyectoReto
//
//  Created by Pedro on 20/11/24.
//

import Foundation

struct Evento: Codable, Identifiable {
    var id = UUID()
    var Descripcion : String
    var FechaInicio : String
    var FechaFinal : String
    var ImagenLink : String
    var Titulo : String
    
    private enum CodingKeys: String, CodingKey {
        case Descripcion
        case FechaInicio
        case FechaFinal
        case ImagenLink
        case Titulo
    }
}

class EventosService : ObservableObject {
    @Published var eventos: [Evento] = []
    
    let apiURLEventos = "https://r1aguilar.pythonanywhere.com/eventos"
    
    func fetchEventos() {
        guard let url = URL(string: apiURLEventos) else {
            print("Url Invalida")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error al obtener eventos: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Datos invalidos")
                return
            }
            
            do {
                let eventos = try JSONDecoder().decode([Evento].self, from: data)
                DispatchQueue.main.async {
                    self.eventos = eventos
                }
            } catch {
                print("Error al decodificar JSON")
            }
        }.resume()
    }
}
