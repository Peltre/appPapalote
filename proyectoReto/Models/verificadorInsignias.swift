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
            return verificador.actividadesCompletadasInterna.count >= 5
        }
        verificaciones[2] = { verificador in
            // Condition for Insignia 2: Completed activities count should be >= 10
            return verificador.actividadesCompletadasInterna.count >= 10
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

            // Save the updated list back to the local JSON file
            do {
                let jsonData = try JSONEncoder().encode(localInsigniasCompletadas)
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
