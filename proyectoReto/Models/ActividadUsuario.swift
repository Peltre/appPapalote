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
    
    // CodingKeys para mapear las propiedades al JSON
    enum CodingKeys: String, CodingKey {
        case id_usuario = "id_usuario"
        case id_actividad = "id_actividad"
        case fecha = "fecha"
    }
    
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
    
    static func crearActividadUsuarioLocal(idUsuario: Int, idActividad: Int, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let localFileActividades = documentsDirectory?.appendingPathComponent("actividadesCompletadas.json") else {
            completion(false)
            return
        }
        
        // Step 1: Decode the existing JSON to obtain the list of ActividadUsuario
        var actividadesCompletadas: [ActividadUsuario] = []
        if fileManager.fileExists(atPath: localFileActividades.path) {
            do {
                let data = try Data(contentsOf: localFileActividades)
                actividadesCompletadas = try JSONDecoder().decode([ActividadUsuario].self, from: data)
            } catch {
                print("Error al leer o decodificar el archivo actividadesCompletadas.json: \(error)")
                completion(false)
                return
            }
        }
        
        // Step 2: Create a new ActividadUsuario with the current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fechaString = dateFormatter.string(from: Date()) // Get the current date as a string
        
        let nuevaActividad = ActividadUsuario(id_usuario: idUsuario, id_actividad: idActividad, fecha: fechaString)
        
        // Step 3: Append the new ActividadUsuario to the list
        actividadesCompletadas.append(nuevaActividad)
        
        // Step 4: Write the updated list back to the local file
        do {
            let updatedData = try JSONEncoder().encode(actividadesCompletadas)
            try updatedData.write(to: localFileActividades)
            print("Actividad añadida y archivo actualizado correctamente.")
            completion(true)
        } catch {
            print("Error al guardar el archivo actividadesCompletadas.json: \(error)")
            completion(false)
        }
    }

}

