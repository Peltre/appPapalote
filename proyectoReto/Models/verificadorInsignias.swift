import Foundation

class VerificadorInsignias {
    static let shared = VerificadorInsignias()
    
    // A dictionary to map insignia IDs to their verification closure
    private var verificaciones: [Int: (_ verificador: VerificadorInsignias) -> Bool] = [:]
    
    // Internal variable to hold the list of completed activities
    private var actividadesCompletadasInterna: [ActividadUsuario] = []
    
    private init() {
        // Example of adding verifications with conditions based on completed activities
        verificaciones[1] = { verificador in
            // Condition for Insignia 1: Completed activities count should be >= 5
            return verificador.actividadesCompletadasInterna.count >= 1
        }
        verificaciones[2] = { verificador in
            // Condition for Insignia 2: Completed activities count should be >= 10
            return verificador.actividadesCompletadasInterna.count >= 5
        }
        verificaciones[3] = { verificador in
            // Condition for Insignia 2: Completed activities count should be >= 10
            return verificador.actividadesCompletadasInterna.count >= 10
        }
        verificaciones[4] = { verificador in
            // Obtener las actividades filtradas por la zona 2
            let actividadesZona2 = ActividadesDataManager.shared.obtenerActividadesPorZona(2)
            
            // Filtrar las actividades para quedarnos solo con las actividades cuyo 'completar' sea 1
            let actividadesFiltradasZona2 = actividadesZona2.filter { $0.completar == 1 }
            
            // Obtener la lista de 'actividad_usuario' del verificador
            let actividadesUsuario = verificador.actividadesCompletadasInterna
            
            // Filtrar las actividades del usuario, quedándonos solo con las que tienen 'id_actividad'
            let actividadesUsuarioIds = actividadesUsuario.map { $0.id_actividad }
            
            // Ahora, mapeamos y filtramos las actividades para obtener los ID de las actividades que coincidan
            let actividadesCoincidentes = actividadesFiltradasZona2.filter { actividad in
                actividadesUsuarioIds.contains(actividad.idActividad)
            }
            
            // Comparar la cantidad de actividades coincidentes con el valor esperado
            let cantidadCoincidentes = actividadesCoincidentes.count
            let cantidadEsperada = TotalActividadesPorCompletarPorZona[1] // Asumiendo que 'TotalActividadesPorCompletarPorZona' es un array
            
            // Si la cantidad de actividades coincidentes es igual a la cantidad esperada, retornamos true
            return cantidadCoincidentes == cantidadEsperada
        }
    }
    
    // Method to verify all insignias and return the new insignias if any
    func verificarInsignias() -> [Insignia]? {
        var newInsignias: [Insignia] = []

        // Decode the actividadesCompletadas from the local JSON
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let localFileActividades = documentsDirectory?.appendingPathComponent("actividadesCompletadas.json"),
              let localFileInsignias = documentsDirectory?.appendingPathComponent("insigniasCompletadas.json") else {
            return nil
        }

        // Load completed activities into the internal list
        if fileManager.fileExists(atPath: localFileActividades.path) {
            do {
                let data = try Data(contentsOf: localFileActividades)
                actividadesCompletadasInterna = try JSONDecoder().decode([ActividadUsuario].self, from: data)
                print("lista obtenida de actividadesCompletadas.json: \(actividadesCompletadasInterna)")
            } catch {
                print("Error al leer o decodificar el archivo actividadesCompletadas.json: \(error)")
                return nil
            }
        }

        // Load completed insignias from the local JSON
        var localInsigniasCompletadas: [UserInsignia] = []
        if fileManager.fileExists(atPath: localFileInsignias.path) {
            do {
                let data = try Data(contentsOf: localFileInsignias)
                localInsigniasCompletadas = try JSONDecoder().decode([UserInsignia].self, from: data)
                print("lista obtenida de insigniasCompletadas.json: \(localInsigniasCompletadas)")
            } catch {
                print("Error al leer o decodificar el archivo insigniasCompletadas.json: \(error)")
                return nil
            }
        }

        // Loop through the verifications and check each condition
        for (insigniaId, verification) in verificaciones {
            if verification(self) {
                // If the insignia is completed, check if it's already in the set of completed insignias
                if !insigniasCompletadasSet.contains(insigniaId) {
                    // If not, add it to newInsignias
                    if let insignia = insignias.first(where: { $0.InsigniaId == insigniaId }) {
                        newInsignias.append(insignia)
                        // Add to the global set to mark it as completed
                        insigniasCompletadasSet.insert(insigniaId)
                    }
                }
            }
        }

        // If there are new insignias, update the local JSON
        if !newInsignias.isEmpty {
            
            // Insert each InsigniaID into the global set
            for insignia in newInsignias {
                insigniasCompletadasSet.insert(insignia.InsigniaId)
            }
            
            print("Nuevo set de insignias interno \(insigniasCompletadasSet)")
            
            // Create the current date string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fechaActual = dateFormatter.string(from: Date())

            // Add new UserInsignia entries to the local list
            for insignia in newInsignias {
                let nuevaInsigniaCompletada = UserInsignia(
                    UserID: usuarioGlobal!.idUsuario, // Replace with the correct UserID as needed
                    InsigniaID: insignia.InsigniaId,
                    FechaCompletado: fechaActual
                )
                localInsigniasCompletadas.append(nuevaInsigniaCompletada)
            }
            
            print("Lista para guardar en el JSON local de insignias completadas \(localInsigniasCompletadas)")

            // Save the updated list back to the local JSON file
            do {
                let jsonData = try JSONEncoder().encode(localInsigniasCompletadas)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Contenido del JSON a guardar:\n\(jsonString)")
                }
                try jsonData.write(to: localFileInsignias)
                print("Insignias completadas actualizadas en el archivo local.")
            } catch {
                print("Error al guardar insignias completadas en el archivo local: \(error)")
            }
        }

        // Return the list of new insignias, or nil if none
        return newInsignias.isEmpty ? nil : newInsignias
    }

}
