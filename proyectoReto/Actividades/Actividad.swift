//
//  Actividad.swift
//  proyectoReto
//
//  Created by Carlos Eugenio Saldaña Tijerina on 17/10/24.
//


//
//  Actividad.swift
//  ViewActividadPapalote
//
//  Created by Alumno on 15/10/24.
//

import Foundation


struct Actividad: Identifiable, Codable {
    var id = UUID()
    var id_zona : Int
    var nombre: String
    var descripcion: String
    var icono: String
}

extension Actividad {
    static let datosEjemplo = [
        Actividad(id_zona: 1, nombre: "JENGA", descripcion: "Participa en un twist en el famoso juego de destreza JENGA.", icono: "cube.fill"), // Expreso
        Actividad(id_zona: 2, nombre: "SUCULENTAS", descripcion: "Arma y colorea tu suculenta del desierto favorita.", icono: "leaf.fill"), // Soy
        Actividad(id_zona: 3, nombre: "SUPERMERCADO", descripcion: "Compra huevos y pan", icono: "cart.fill"), // Pequeños
        Actividad(id_zona: 4, nombre: "VIENTO", descripcion: "No creerás lo que carga el viento y hasta dónde llega", icono: "wind"), // Comprendo
        Actividad(id_zona: 8, nombre: "PLANTAS", descripcion: "Conoce la biodiversidad del lugar", icono: "leaf.arrow.triangle.circlepath"), // Pertenezco
        Actividad(id_zona: 9, nombre: "HABLA", descripcion: "Descubre el poder de la comunicación", icono: "message.fill") // Comunico
    ]
}

