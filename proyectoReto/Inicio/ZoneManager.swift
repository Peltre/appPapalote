import Foundation

struct Zona2: Identifiable, Codable {
    var id: Int
    var nombre: String
    var completado: Bool
    var imagen: String
}

class ZonasData: ObservableObject {
    @Published var zonas: [Zona2] = [
        Zona2(id: 1, nombre: "Expreso", completado: false, imagen: "IconoExpreso"),
        Zona2(id: 2, nombre: "Comunico", completado: false, imagen: "IconoComunico"),
        Zona2(id: 3, nombre: "Pertenezco", completado: false, imagen: "IconoPertenezco"),
        Zona2(id: 4, nombre: "Comprendo", completado: false, imagen: "IconoComprendo"),
        Zona2(id: 5, nombre: "Soy", completado: false, imagen: "IconoSoy"),
        Zona2(id: 6, nombre: "Pequenos", completado: false, imagen: "IconoPeque")
    ] {
        didSet {
            saveState()
        }
    }
    
    init() {
        loadState()  // Carga el estado guardado cuando se inicia la app
    }
    
    func saveState() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(zonas) {
            let url = getDocumentsDirectory().appendingPathComponent("zonas2.json")
            try? data.write(to: url)
        }
    }
    
    func loadState() {
        let url = getDocumentsDirectory().appendingPathComponent("zonas2.json")
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedZonas = try? decoder.decode([Zona2].self, from: data) {
                zonas = decodedZonas
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// Estructura de Zona3
struct Zona3: Identifiable, Codable, Equatable {
    var id: Int
    var nombre: String
    var numActividades: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id_zona"
        case nombre
        case numActividades = "num_Actividades"
    }
}

class ZonasData2: ObservableObject {
    @Published var zonas : [Zona3] = []
    
    init() {
        loadZonas()
    }
    
    func loadZonas() {
        guard let url = URL(string: "\(apiURLbase)zonas") else {
            print("URL inválida.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Manejo de errores
            if let error = error {
                print("Error al realizar la solicitud: \(error.localizedDescription)")
                return
            }
            
            // Verificación del estado de la respuesta
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: respuesta no válida")
                return
            }
            
            // Manejo de datos
            guard let data = data else {
                print("No se recibieron datos.")
                return
            }
            
            do {
                // Decodificación de la respuesta
                let decodedZonas = try JSONDecoder().decode([Zona3].self, from: data)
                print(decodedZonas)
                // Actualización en el hilo principal
                DispatchQueue.main.async {
                    self.zonas = decodedZonas
                }
            } catch {
                print("Error al decodificar los datos: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    // Función para obtener la lista de zonas completadas
    func obtenerListaZonasCompletadas(completion: @escaping ([Bool]?) -> Void) {
        guard let url = URL(string: "\(apiURLbase)zonas_completadas_usuario") else {
            print("URL inválida.")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Cuerpo de la solicitud con el ID del usuario
        let body: [String: Any] = ["id_usuario": usuarioGlobal!.idUsuario]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Manejo de errores
            if let error = error {
                print("Error al realizar la solicitud: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Verificación del estado de la respuesta
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: respuesta no válida")
                completion(nil)
                return
            }
            
            // Manejo de datos
            guard let data = data else {
                print("No se recibieron datos.")
                completion(nil)
                return
            }
            
            do {
                // Decodificación de la respuesta
                let booleanos = try JSONDecoder().decode([Bool].self, from: data)
                print("Imprimiendo booleanos \(booleanos)")
                // Retornar la lista de booleanos
                DispatchQueue.main.async {
                    completion(booleanos)
                }
            } catch {
                print("Error al decodificar los datos: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
}

//class ZonasData3: ObservableObject {
//    @Published var zonas: [Zona3] = []
//
//    init() {
//        loadState() // Cargar el estado de las zonas y luego inicializar numActividadesCompletadas
//    }
//
//    private func inicializarNumActividadesCompletadas() {
//        // Definir el tamaño de `numActividadesCompletadasPorZona` en función de la cantidad de zonas
//        let numZonas = zonas.count + 1 // +1 porque IDs empiezan en 1, no en 0
//        numActividadesCompletadasPorZona = Array(repeating: 0, count: numZonas)
//
//        // URL del archivo JSON
//        let url = getDocumentsDirectory().appendingPathComponent("numActividadesCompletadasPorZona.json")
//        let fileManager = FileManager.default
//
//        // Verificar si el archivo existe
//        if fileManager.fileExists(atPath: url.path) {
//            // Si el archivo existe, intentar cargar y decodificar los datos
//            if let data = try? Data(contentsOf: url),
//               let savedCounts = try? JSONDecoder().decode([Int].self, from: data) {
//                // Ajustar el tamaño de `numActividadesCompletadasPorZona` para reflejar el nuevo número de zonas
//                let minSize = min(savedCounts.count, numZonas)
//
//                // Copiar los valores decodificados en la lista global hasta el tamaño mínimo
//                for i in 0..<minSize {
//                    numActividadesCompletadasPorZona[i] = savedCounts[i]
//                }
//            }
//        } else {
//            // Si el archivo no existe, guardar la lista inicial (rellena de ceros) en el archivo JSON
//            guardarNumActividadesCompletadas()
//        }
//    }
//
//    func incrementarActividadCompletada(paraZona idZona: Int) {
//        guard idZona > 0 && idZona < numActividadesCompletadasPorZona.count else {
//            print("Error: El idZona está fuera de los límites.")
//            return
//        }
//
//        // Incrementar el contador de actividades completadas para la zona especificada
//        numActividadesCompletadasPorZona[idZona] += 1
//
//        // Guardar el nuevo estado en el archivo JSON
//        guardarNumActividadesCompletadas()
//    }
//
//    func decrementarActividadCompletada(paraZona idZona: Int) {
//        guard idZona > 0 && idZona < numActividadesCompletadasPorZona.count else {
//            print("Error: El idZona está fuera de los límites.")
//            return
//        }
//
//        // Incrementar el contador de actividades completadas para la zona especificada
//        numActividadesCompletadasPorZona[idZona] -= 1
//
//        // Guardar el nuevo estado en el archivo JSON
//        guardarNumActividadesCompletadas()
//    }
//
//    private func guardarNumActividadesCompletadas() {
//        // Guardar `numActividadesCompletadasPorZona` en JSON
//        let url = getDocumentsDirectory().appendingPathComponent("numActividadesCompletadasPorZona.json")
//        if let data = try? JSONEncoder().encode(numActividadesCompletadasPorZona) {
//            try? data.write(to: url)
//        }
//    }
//
//    func loadState() {
//        let url = getDocumentsDirectory().appendingPathComponent("zonas3.json")
//        let fileManager = FileManager.default
//
//        if fileManager.fileExists(atPath: url.path) {
//            if let localData = try? Data(contentsOf: url),
//               let decodedZonas = try? JSONDecoder().decode([Zona3].self, from: localData) {
//                self.zonas = decodedZonas
//                inicializarNumActividadesCompletadas() // Inicializar la lista global después de cargar las zonas
//                verificarDatosConServidor(localZonas: decodedZonas)
//            }
//        } else {
//            obtenerDatosDesdeServidor()
//        }
//    }
//
//    private func verificarDatosConServidor(localZonas: [Zona3]) {
//        guard let urlEndpoint = URL(string: apiURLbase + "zonas") else { return }
//
//        URLSession.shared.dataTask(with: urlEndpoint) { data, response, error in
//            guard let data = data, error == nil,
//                  let serverZonas = try? JSONDecoder().decode([Zona3].self, from: data) else {
//                print("Error al obtener datos del servidor: \(error?.localizedDescription ?? "Desconocido")")
//                return
//            }
//
//            if serverZonas != localZonas {
//                DispatchQueue.main.async {
//                    self.guardarDatosLocalmente(zonas: serverZonas)
//                    self.zonas = serverZonas
//                    self.inicializarNumActividadesCompletadas() // Recalcular si los datos cambian
//                }
//            }
//        }.resume()
//    }
//
//    private func obtenerDatosDesdeServidor() {
//        guard let urlEndpoint = URL(string: apiURLbase + "zonas") else { return }
//
//        URLSession.shared.dataTask(with: urlEndpoint) { data, response, error in
//            guard let data = data, error == nil,
//                  let serverZonas = try? JSONDecoder().decode([Zona3].self, from: data) else {
//                print("Error al obtener datos del servidor: \(error?.localizedDescription ?? "Desconocido")")
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.guardarDatosLocalmente(zonas: serverZonas)
//                self.zonas = serverZonas
//                self.inicializarNumActividadesCompletadas() // Recalcular después de obtener datos del servidor
//            }
//        }.resume()
//    }
//
//    private func guardarDatosLocalmente(zonas: [Zona3]) {
//        let url = getDocumentsDirectory().appendingPathComponent("zonas3.json")
//        if let data = try? JSONEncoder().encode(zonas) {
//            try? data.write(to: url)
//        }
//    }
//
//    func getDocumentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//}
