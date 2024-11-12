//
//  ActividadUsuario.swift
//  proyectoReto
//
//  Created by user254414 on 10/29/24.
//

import Foundation

struct ActividadUsuario: Codable {
    var id_usuario: Int
    var id_actividad: Int
    var fecha: String  // Cambiar a String para el formato deseado
    
    static func crearActividadUsuario(idUsuario: Int, idActividad: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: apiURLbase + "crear_actividad_usuario") else {
            print("URL no válida")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Formatear la fecha en el formato YYYY-MM-DD
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fechaString = dateFormatter.string(from: Date()) // Obtener la fecha actual en el formato deseado
        
        let actividadUsuario = ActividadUsuario(id_usuario: idUsuario, id_actividad: idActividad, fecha: fechaString)
        
        do {
            let jsonData = try JSONEncoder().encode(actividadUsuario)
            request.httpBody = jsonData
        } catch {
            print("Error al codificar el JSON: \(error)")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud: \(error)")
                completion(false)
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Error en la respuesta del servidor")
                completion(false)
                return
            }
            
            if let data = data {
                // Aquí puedes manejar la respuesta si es necesario
                print("Actividad creada con éxito: \(data)")
                completion(true)
            }
        }
        task.resume()
    }
}

