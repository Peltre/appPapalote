//
//  proyectoRetoApp.swift
//  proyectoReto
//
//  Created by Pedr1p on 12/10/24.
//

import SwiftUI
import Foundation

@main
struct proyectoRetoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var usuario: user?
    @State private var isLoadingActividadesCompletadas = false
    @State private var isLoadingInsignias = false
    @State private var isLoadingInsigniasCompletadas = false
    @EnvironmentObject var perfilViewModel: PerfilViewModel
    
    init() {
        _ = ActividadesDataManager.shared
        // Necesitamos usar _usuario para modificar el State directamente en init
        _usuario = State(initialValue: cargarUsuarioInicial())
    }
    
    var body: some Scene {
        WindowGroup {
            if usuario != nil {
                InicioOverhaul(idZona: 2)
                    .environmentObject(PerfilViewModel()) // Proporciona el ViewModel como EnvironmentObject
            } else {
                SignIn()
                    .environmentObject(PerfilViewModel()) // Proporciona el ViewModel como EnvironmentObject

            }
            
        }
    }
    
    private func cargarUsuarioInicial() -> user? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json")
        
        guard let url = fileURL else {
            print("No hace el url")
            return nil
        }
        
        do {
            let datosRecuperados = try Data(contentsOf: url)
            if let jsonString = String(data: datosRecuperados, encoding: .utf8) {
                print("Contenido del archivo JSON: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let usuarioCargado = try decoder.decode(user.self, from: datosRecuperados)
            print("Usuario cargado exitosamente: \(usuarioCargado)")
            actualizarUsuarioDB(usuario: usuarioCargado)
            loadActividadesCompletadas(for: usuarioCargado.idUsuario)
            obtenerInsignias()
            loadInsigniasCompletadas(for: usuarioCargado.idUsuario)
            usuarioGlobal = usuarioCargado
            return usuarioCargado
        } catch {
            print("Error cargando usuario: \(error)")
            return nil
        }
    }
    
    // Función para cargar actividades completadas
    private func loadActividadesCompletadas(for idUsuario: Int) {
        guard !isLoadingActividadesCompletadas else { return } // Evitar múltiples cargas
        isLoadingActividadesCompletadas = true
        
        obtenerActividadesCompletadas2(idUsuario: idUsuario) { completadas in
            actividadesCompletadas = completadas
            isLoadingActividadesCompletadas = false // Cambiar el estado de carga a false después de obtener los datos
        }
    }
    
    // Función para cargar actividades completadas
    private func loadInsigniasCompletadas(for idUsuario: Int) {
        guard !isLoadingInsigniasCompletadas else { return } // Evitar múltiples cargas
        isLoadingInsigniasCompletadas = true
        
        fetchInsigniasCompletadas(idUsuario: idUsuario)
    }
}

func obtenerActividadesCompletadas(idUsuario: Int, completion: @escaping ([Bool]) -> Void) {
    guard let url = URL(string: apiURLbase + "actividades_completadas") else {
        print("URL no válida")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parametros = ["id_usuario": idUsuario]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: parametros) else {
        print("Error al codificar el JSON")
        return
    }
    
    request.httpBody = jsonData
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error en el request: \(error)")
            completion([]) // Retornar un arreglo vacío en caso de error
            return
        }
        
        guard let data = data else {
            print("No se recibieron datos")
            completion([]) // Retornar un arreglo vacío en caso de error
            return
        }
        
        if let actividades = try? JSONDecoder().decode([Bool].self, from: data) {
            print(actividades)
            DispatchQueue.main.async {
                completion(actividades) // Llamar al closure con los datos decodificados
            }
        } else {
            print("Error al decodificar la respuesta JSON")
            completion([]) // Retornar un arreglo vacío en caso de error
        }
    }.resume()
}

var numActividades : Int = 0

var actividadesCompletadas: [Bool] = Array(repeating: false, count: 80)

var TotalActividadesPorCompletarPorZona : [Int] = [Int]()

var numActividadesCompletadasPorZona : [Int] = [Int]()

var usuarioGlobal : user? = nil

var insignias : [Insignia] = [Insignia]()

var insigniasCompletadas : [UserInsignia] = [UserInsignia]()

var insigniasCompletadasSet = Set<Int>()

func obtenerActividadesCompletadas2(idUsuario: Int, completion: @escaping ([Bool]) -> Void) {
    guard let urlNumeroActividades = URL(string: apiURLbase + "numero_actividades"),
          let urlActividadesCompletadas = URL(string: apiURLbase + "actividades_completadas_usuario"),
          let urlSincronizar = URL(string: apiURLbase + "sincronizar_actividades_completadas") else {
        print("URLs no válidas")
        return
    }

    // Local file paths setup
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    let localFileNumeroActividades = documentsDirectory?.appendingPathComponent("numeroActividades.json")
    let localFileActividades = documentsDirectory?.appendingPathComponent("actividadesCompletadas.json")

    // Step 1: Fetch total activities with local fallback
    func fetchTotalActividades() {
        // Función auxiliar para cargar datos locales
        func loadLocalTotalActividades() -> [Int]? {
            guard let localFileURL = localFileNumeroActividades,
                  fileManager.fileExists(atPath: localFileURL.path),
                  let localData = try? Data(contentsOf: localFileURL),
                  let localTotal = try? JSONDecoder().decode([Int].self, from: localData) else {
                return nil
            }
            return localTotal
        }
        
        // Si ya tenemos datos locales, los cargamos primero para asegurar que nunca esté vacío
        if let localTotal = loadLocalTotalActividades() {
            TotalActividadesPorCompletarPorZona = localTotal
        }

        var requestNumeroActividades = URLRequest(url: urlNumeroActividades)
        requestNumeroActividades.httpMethod = "GET"

        URLSession.shared.dataTask(with: requestNumeroActividades) { data, response, error in
            if let error = error {
                print("Error en el request de total actividades: \(error)")
                // Ya tenemos los datos locales cargados, así que no hacemos nada más
                return
            }

            guard let data = data,
                  let totalResponse = try? JSONDecoder().decode([Int].self, from: data) else {
                print("Error al decodificar el total de actividades")
                return
            }

            // Actualizar el archivo local con los nuevos datos del API
            if let localFileURL = localFileNumeroActividades {
                do {
                    try data.write(to: localFileURL)
                    print("Datos guardados en archivo local numeroActividades.json")
                    TotalActividadesPorCompletarPorZona = totalResponse
                } catch {
                    print("Error al guardar el archivo local numeroActividades.json: \(error)")
                }
            }
        }.resume()
    }

    // Step 2: Fetch completed activities with local priority
    func fetchActividadesCompletadas(idUsuario: Int, completion: @escaping ([Bool]) -> Void) {
        // Función auxiliar para cargar datos locales
        func loadLocalActividades() -> [ActividadUsuario]? {
            guard let localFileURL = localFileActividades,
                  fileManager.fileExists(atPath: localFileURL.path),
                  let localData = try? Data(contentsOf: localFileURL),
                  let localActividades = try? JSONDecoder().decode([ActividadUsuario].self, from: localData) else {
                return nil
            }
            return localActividades
        }

        // Cargar datos locales primero
        let actividadesCompletadasLocal = loadLocalActividades() ?? []
        let isFirstTime = actividadesCompletadasLocal.isEmpty

        // Preparar request para API
        var requestActividadesCompletadas = URLRequest(url: urlActividadesCompletadas)
        requestActividadesCompletadas.httpMethod = "POST"
        requestActividadesCompletadas.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parametros = ["id_usuario": idUsuario]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parametros) else {
            print("Error al codificar el JSON de actividades completadas")
            // Usar datos locales si están disponibles, o array vacío si no
            let actividadesBool = generarArrayBooleano(from: actividadesCompletadasLocal)
            completion(actividadesBool)
            return
        }
        
        requestActividadesCompletadas.httpBody = jsonData

        URLSession.shared.dataTask(with: requestActividadesCompletadas) { data, response, error in
            if let error = error {
                print("Error en el request de actividades completadas: \(error)")
                // Usar datos locales existentes
                let actividadesBool = generarArrayBooleano(from: actividadesCompletadasLocal)
                DispatchQueue.main.async {
                    completion(actividadesBool)
                }
                return
            }

            guard let data = data,
                  let actividadesAPI = try? JSONDecoder().decode([ActividadUsuario].self, from: data) else {
                print("Error al decodificar actividades completadas desde la API")
                // Usar datos locales existentes
                let actividadesBool = generarArrayBooleano(from: actividadesCompletadasLocal)
                DispatchQueue.main.async {
                    completion(actividadesBool)
                }
                return
            }

            if isFirstTime {
                // Primera vez: usar datos del API y guardarlos localmente
                if let localFileURL = localFileActividades {
                    do {
                        let dataToSave = try JSONEncoder().encode(actividadesAPI)
                        try dataToSave.write(to: localFileURL)
                        print("Archivo local inicializado con datos de la API")
                        let actividadesBool = generarArrayBooleano(from: actividadesAPI)
                        DispatchQueue.main.async {
                            completion(actividadesBool)
                        }
                    } catch {
                        print("Error al escribir en el archivo local: \(error)")
                        completion([Bool](repeating: false, count: numActividades + 1))
                    }
                }
            } else {
                // No es primera vez: usar datos locales y sincronizar nuevos al API
                let nuevasActividades = actividadesCompletadasLocal.filter { local in
                    !actividadesAPI.contains(where: { $0.id_actividad == local.id_actividad })
                }

                if !nuevasActividades.isEmpty {
                    sincronizarConAPI(nuevasActividades: nuevasActividades, urlSincronizar: urlSincronizar)
                }

                // Usar datos locales para la respuesta
                let actividadesBool = generarArrayBooleano(from: actividadesCompletadasLocal)
                DispatchQueue.main.async {
                    completion(actividadesBool)
                }
            }
        }.resume()
    }

    // Función auxiliar para generar array booleano
    func generarArrayBooleano(from actividades: [ActividadUsuario]) -> [Bool] {
        var actividadesBool = [Bool](repeating: false, count: numActividades + 1)
        for actividad in actividades {
            if actividad.id_actividad >= 0 && actividad.id_actividad < actividadesBool.count {
                actividadesBool[actividad.id_actividad] = true
            }
        }
        return actividadesBool
    }

    // Función auxiliar para sincronizar con API
    func sincronizarConAPI(nuevasActividades: [ActividadUsuario], urlSincronizar: URL) {
        var requestSincronizar = URLRequest(url: urlSincronizar)
        requestSincronizar.httpMethod = "POST"
        requestSincronizar.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let syncData = try? JSONEncoder().encode(nuevasActividades) else {
            print("Error al codificar el JSON para sincronizar")
            return
        }
        
        requestSincronizar.httpBody = syncData
        URLSession.shared.dataTask(with: requestSincronizar) { _, _, _ in
            print("Sincronización completada")
        }.resume()
    }

    // Ejecutar los pasos
    fetchTotalActividades()
    fetchActividadesCompletadas(idUsuario: idUsuario) { actividadesBool in
        completion(actividadesBool)
    }
}

func obtenerInsignias() {
    // Función auxiliar para leer datos locales
    func readLocalData() -> [Insignia] {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("No se pudo obtener el directorio de documentos")
            return []
        }
        let localFileURL = documentsDirectory.appendingPathComponent("insignias.json")
        
        if fileManager.fileExists(atPath: localFileURL.path) {
            do {
                let localData = try Data(contentsOf: localFileURL)
                let localInsignias = try JSONDecoder().decode([Insignia].self, from: localData)
                print("Insignias cargadas desde el archivo local")
                return localInsignias
            } catch {
                print("Error al leer o decodificar datos locales: \(error)")
                return []
            }
        }
        return []
    }
    
    // Función auxiliar para guardar datos localmente
    func saveDataLocally(_ insigniasData: [Insignia]) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("No se pudo obtener el directorio de documentos")
            return
        }
        let localFileURL = documentsDirectory.appendingPathComponent("insignias.json")
        
        do {
            let jsonData = try JSONEncoder().encode(insigniasData)
            try jsonData.write(to: localFileURL)
            print("Insignias guardadas en: \(localFileURL.path)")
        } catch {
            print("Error al guardar datos localmente: \(error)")
        }
    }
    
    // Función auxiliar para actualizar variables globales
    func updateGlobalVariables(with insigniasData: [Insignia]) {
        DispatchQueue.main.async {
            insignias = insigniasData
            print("Variables globales actualizadas con \(insigniasData.count) insignias")
        }
    }
    
    // Preparar la llamada al API
    guard let url = URL(string: apiURLbase + "insignias") else {
        print("URL no válida")
        // Si la URL no es válida, usar datos locales
        let localInsignias = readLocalData()
        updateGlobalVariables(with: localInsignias)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error en el request: \(error)")
            // Si hay error en la llamada, usar datos locales
            let localInsignias = readLocalData()
            updateGlobalVariables(with: localInsignias)
            return
        }
        
        if let data = data {
            do {
                // Decodificar la respuesta del API
                let insigniasAPI = try JSONDecoder().decode([Insignia].self, from: data)
                
                // Guardar los datos del API localmente
                saveDataLocally(insigniasAPI)
                
                // Actualizar variables globales con datos del API
                updateGlobalVariables(with: insigniasAPI)
            } catch {
                print("Error al decodificar datos del API: \(error)")
                // Si hay error al decodificar, usar datos locales
                let localInsignias = readLocalData()
                updateGlobalVariables(with: localInsignias)
            }
        } else {
            print("No se recibieron datos del API, usando datos locales")
            // Si no hay datos del API, usar datos locales
            let localInsignias = readLocalData()
            updateGlobalVariables(with: localInsignias)
        }
    }.resume()
}

func fetchInsigniasCompletadas(idUsuario: Int) {
    // Obtener la URL del archivo local
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("No se pudo obtener el directorio de documentos")
        return
    }
    let localFileURL = documentsDirectory.appendingPathComponent("insigniasCompletadas.json")
    
    // Función auxiliar para actualizar las variables globales
    func updateGlobalVariables(with insignias: [UserInsignia]) {
        DispatchQueue.main.async {
            insigniasCompletadas = insignias
            insigniasCompletadasSet = Set(insignias.map { $0.InsigniaID })
            print("Insignias Completadas actualizadas: \(insignias.count) insignias")
        }
    }
    
    // Función auxiliar para leer datos locales
    func readLocalData() -> [UserInsignia] {
        if fileManager.fileExists(atPath: localFileURL.path),
           let localData = try? Data(contentsOf: localFileURL),
           let localInsignias = try? JSONDecoder().decode([UserInsignia].self, from: localData) {
            return localInsignias
        }
        return []
    }
    
    // Función auxiliar para guardar datos localmente
    func saveDataLocally(_ insignias: [UserInsignia]) {
        do {
            let jsonData = try JSONEncoder().encode(insignias)
            try jsonData.write(to: localFileURL)
            print("Datos de insignias guardados localmente")
        } catch {
            print("Error al guardar datos localmente: \(error)")
        }
    }
    
    // Función auxiliar para sincronizar con el servidor
    func syncWithServer(newInsignias: [UserInsignia]) {
        guard let urlSincronizar = URL(string: apiURLbase + "sincronizar_insignias_completadas") else {
            print("URL no válida para sincronizar las insignias")
            return
        }

        var requestSincronizar = URLRequest(url: urlSincronizar)
        requestSincronizar.httpMethod = "POST"
        requestSincronizar.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let syncData = try? JSONEncoder().encode(newInsignias) else {
            print("Error al codificar las nuevas insignias para sincronizar")
            return
        }

        requestSincronizar.httpBody = syncData

        URLSession.shared.dataTask(with: requestSincronizar) { _, _, error in
            if let error = error {
                print("Error al sincronizar las insignias: \(error)")
            } else {
                print("Sincronización de insignias completadas exitosa")
            }
        }.resume()
    }
    
    // Preparar la llamada al API
    guard let urlInsigniasCompletadas = URL(string: apiURLbase + "obtener_insignias_usuario") else {
        print("URL no válida para obtener las insignias completadas")
        let localInsignias = readLocalData()
        updateGlobalVariables(with: localInsignias)
        return
    }

    var request = URLRequest(url: urlInsigniasCompletadas)
    request.httpMethod = "POST"
    
    let parameters = ["id_usuario": idUsuario]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
        print("Error al codificar los parámetros para el request")
        let localInsignias = readLocalData()
        updateGlobalVariables(with: localInsignias)
        return
    }
    
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        // Leer datos locales primero
        let localInsignias = readLocalData()
        
        // Si hay error en la llamada API o no hay datos
        if error != nil || data == nil {
            print("Error en el request de insignias completadas o no hay datos")
            updateGlobalVariables(with: localInsignias)
            return
        }
        
        // Procesar respuesta del API
        if let data = data {
            do {
                let insigniasAPI = try JSONDecoder().decode([UserInsignia].self, from: data)
                
                if localInsignias.isEmpty {
                    // Si el archivo local está vacío, guardar datos del API
                    saveDataLocally(insigniasAPI)
                    updateGlobalVariables(with: insigniasAPI)
                } else {
                    // Encontrar insignias nuevas que están en local pero no en API
                    let newInsignias = localInsignias.filter { localInsignia in
                        !insigniasAPI.contains { apiInsignia in
                            apiInsignia.InsigniaID == localInsignia.InsigniaID &&
                            apiInsignia.UserID == localInsignia.UserID
                        }
                    }
                    
                    // Si hay nuevas insignias, sincronizar con el servidor
                    if !newInsignias.isEmpty {
                        syncWithServer(newInsignias: newInsignias)
                    }
                    
                    // Usar los datos locales como fuente de verdad
                    updateGlobalVariables(with: localInsignias)
                }
            } catch {
                print("Error al decodificar respuesta del API: \(error)")
                updateGlobalVariables(with: localInsignias)
            }
        }
    }.resume()
}

func actualizarUsuarioDB(usuario : user) {
    guard let url = URL(string: apiURLbase + "modificar_usuario") else {
        print("URL Inválida")
        return
    }
    
    // Crear el diccionario solo con los campos necesarios
    let datosActualizados: [String: Any] = [
        "id": usuario.idUsuario,
        "username": usuario.username,  // nuevo nombre de usuario
        "pfp": usuario.pfp + 1        // pfp sin cambios
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: datosActualizados) else {
        print("Error al serializar los datos")
        return
    }
    
    print("JSON enviado al servidor:", String(data: jsonData, encoding: .utf8) ?? "Error al convertir JSON a string")
    
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error en la solicitud: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Respuesta del servidor no válida")
            return
        }
        
        if httpResponse.statusCode == 200 {
            print("Datos actualizados correctamente")
        } else {
            print("Error del servidor: \(httpResponse.statusCode)")
            if let data = data {
                print("Respuesta del servidor:", String(data: data, encoding: .utf8) ?? "No se pudo leer la respuesta")
            }
        }
    }.resume()
}

