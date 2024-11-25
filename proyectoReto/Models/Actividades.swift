//
//  Actividades.swift
//  proyectoReto
//
//  Created by user273350 on 11/22/24.
//

import Foundation

// Clase que representa una Actividad
struct Actividad2: Identifiable, Codable {
    let id = UUID()
    let idActividad: Int
    let idZona: Int
    let nombre: String
    let listaTarjetas: [Tarjeta]
    let completar : Int

    // CodingKeys para mapear las propiedades al JSON
    enum CodingKeys: String, CodingKey {
        case idActividad = "id_actividad"
        case idZona = "id_zona"
        case nombre = "nombre"
        case listaTarjetas = "tarjetas"
        case completar = "completar"
    }
}

extension Actividad2 {
    static let datosEjemplo = [
        Actividad2(idActividad: 1, idZona: 3, nombre: "JENGA", listaTarjetas: Tarjeta.datosEjemplo, completar: 1),
        Actividad2(idActividad: 2, idZona: 3, nombre: "SUCULENTAS", listaTarjetas: [
            Tarjeta(idTarjeta: 5, tipo: 1, texto: "Elige tu suculenta.", imagenUrl: "", ordenLista: 1),
            Tarjeta(idTarjeta: 6, tipo: 1, texto: "Agrega color a tu creación.", imagenUrl: "", ordenLista: 2)
        ], completar: 0),
        Actividad2(idActividad: 3, idZona: 5, nombre: "SUPERMERCADO", listaTarjetas: [
            Tarjeta(idTarjeta: 7, tipo: 1, texto: "Compra los ingredientes.", imagenUrl: "", ordenLista: 1),
            Tarjeta(idTarjeta: 8, tipo: 1, texto: "No olvides la lista.", imagenUrl: "", ordenLista: 2)
        ], completar: 0),
        Actividad2(idActividad: 4, idZona: 1, nombre: "VIENTO", listaTarjetas: [
            Tarjeta(idTarjeta: 9, tipo: 1, texto: "Observa lo que vuela.", imagenUrl: "", ordenLista: 1),
            Tarjeta(idTarjeta: 10, tipo: 1, texto: "¿A dónde llevará el viento?", imagenUrl: "", ordenLista: 2)
        ], completar: 0),
        Actividad2(idActividad: 5, idZona: 2, nombre: "RADIO", listaTarjetas: [
            Tarjeta(idTarjeta: 9, tipo: 1, texto: "Imagina que eres un locutor.", imagenUrl: "", ordenLista: 1),
            Tarjeta(idTarjeta: 10, tipo: 1, texto: "¿Que le dirias al mundo?", imagenUrl: "", ordenLista: 2)
        ], completar: 0),
        Actividad2(idActividad: 6, idZona: 6, nombre: "SUBMARINO", listaTarjetas: [
            Tarjeta(idTarjeta: 9, tipo: 1, texto: "Sumergente en una aventura.", imagenUrl: "", ordenLista: 1),
            Tarjeta(idTarjeta: 10, tipo: 1, texto: "¿A dónde llevará el subsuelo?", imagenUrl: "", ordenLista: 2)
        ], completar: 0),
        Actividad2(idActividad: 7, idZona: 4, nombre: "BAYLAB", listaTarjetas: [
            Tarjeta(idTarjeta: 9, tipo: 1, texto: "Aprende a experimentar como nunca antes.", imagenUrl: "", ordenLista: 1),
            Tarjeta(idTarjeta: 10, tipo: 1, texto: "Una experiencia inolvidable!", imagenUrl: "", ordenLista: 2)
        ], completar: 0)]
}

// Extensión para hacer comparable Actividad2
extension Actividad2: Equatable {
    static func == (lhs: Actividad2, rhs: Actividad2) -> Bool {
        return lhs.idActividad == rhs.idActividad &&
               lhs.idZona == rhs.idZona &&
               lhs.nombre == rhs.nombre &&
               lhs.listaTarjetas == rhs.listaTarjetas &&
               lhs.completar == rhs.completar
    }
}

class ActividadesDataManager {
    static let shared = ActividadesDataManager()
    @Published private(set) var actividades: [Actividad2] = []
    private let apiURL = URL(string: apiURLbase + "actividades")!
    
    private init() {
        cargarDatosLocales()
        Task {
            await sincronizarDatos()
        }
    }
    
    private func cargarDatosLocales() {
        if let datosRecuperados = try? Data(contentsOf: rutaArchivo()),
           let datosDecodificados = try? JSONDecoder().decode([Actividad2].self, from: datosRecuperados) {
            self.actividades = datosDecodificados
            print("Datos locales cargados: \(datosDecodificados.count) actividades")
            numActividades = datosDecodificados.count
        }
    }
    
    private func rutaArchivo() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("actividades2.json")
    }
    
    func obtenerActividadPorId(_ idActividad: Int) -> Actividad2? {
        return actividades.first { $0.idActividad == idActividad }
    }
    
    private func guardarDatos() {
        if let codificado = try? JSONEncoder().encode(actividades) {
            try? codificado.write(to: rutaArchivo())
        }
    }
    
    func sincronizarDatos() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: apiURL)
            let nuevasActividades = try JSONDecoder().decode([Actividad2].self, from: data)
            
            if nuevasActividades != actividades {
                DispatchQueue.main.async {
                    self.actividades = nuevasActividades
                    self.guardarDatos()
                }
            }
        } catch {
            print("Error sincronizando datos: \(error)")
        }
    }
    
    func obtenerActividadesPorZona(_ idZona: Int) -> [Actividad2] {
        return actividades.filter { $0.idZona == idZona }
    }
}

// ViewModel simplificado
@MainActor
class ActividadesViewModel: ObservableObject {
    @Published private(set) var actividadesFiltradas: [Actividad2] = []
    private let idZona: Int
    
    init(idZona: Int) {
        self.idZona = idZona
        actualizarActividades()
        
        // Observar cambios en ActividadesDataManager
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(actualizarActividades),
                                             name: NSNotification.Name("ActividadesActualizadas"),
                                             object: nil)
    }
    
    @objc private func actualizarActividades() {
        actividadesFiltradas = ActividadesDataManager.shared.obtenerActividadesPorZona(idZona)
    }
    
    /// Método para obtener una actividad específica por su ID
    func obtenerActividadPorId(_ idActividad: Int) -> Actividad2? {
        return ActividadesDataManager.shared.obtenerActividadPorId(idActividad)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
