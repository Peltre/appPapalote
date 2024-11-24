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

class EventosService: ObservableObject {
    @Published var eventos: [Evento] = []
    private let fileName = "eventos.json"
    private let apiURLEventos = apiURLbase + "eventos"
    
    func fetchEventos() {
        guard let url = URL(string: apiURLEventos) else {
            print("URL inválida")
            loadLocalEventos() // Load local data if URL is invalid
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error al obtener eventos: \(error.localizedDescription)")
                self.loadLocalEventos() // Load local data if API call fails
                return
            }
            
            guard let data = data else {
                print("Datos inválidos")
                self.loadLocalEventos() // Load local data if no valid data
                return
            }
            
            do {
                let eventos = try JSONDecoder().decode([Evento].self, from: data)
                DispatchQueue.main.async {
                    self.eventos = eventos
                    self.saveEventosToLocal(eventos) // Save fetched data locally
                }
            } catch {
                print("Error al decodificar JSON: \(error.localizedDescription)")
                self.loadLocalEventos() // Load local data if decoding fails
            }
        }.resume()
    }
    
    private func saveEventosToLocal(_ eventos: [Evento]) {
        guard let fileURL = getLocalFileURL() else {
            print("No se pudo obtener la URL del archivo local")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(eventos)
            try data.write(to: fileURL, options: .atomic)
            print("Eventos guardados localmente en \(fileURL)")
        } catch {
            print("Error al guardar eventos localmente: \(error.localizedDescription)")
        }
    }
    
    private func loadLocalEventos() {
        guard let fileURL = getLocalFileURL() else {
            print("No se pudo obtener la URL del archivo local")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let eventos = try JSONDecoder().decode([Evento].self, from: data)
            DispatchQueue.main.async {
                self.eventos = eventos
                print("Eventos cargados desde el archivo local")
            }
        } catch {
            print("Error al cargar eventos desde el archivo local: \(error.localizedDescription)")
        }
    }
    
    private func getLocalFileURL() -> URL? {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentDirectory?.appendingPathComponent(fileName)
    }
}

