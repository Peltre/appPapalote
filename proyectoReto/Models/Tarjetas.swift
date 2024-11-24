//
//  Tarjetas.swift
//  proyectoReto
//
//  Created by Alumno on 18/10/24.
//

import Foundation

// Clase que representa una Tarjeta
struct Tarjeta: Codable {
    let idTarjeta: Int
    let tipo: Int
    let texto: String?
    let imagenUrl: String?
    let ordenLista: Int

    // CodingKeys para mapear las propiedades al JSON
    enum CodingKeys: String, CodingKey {
        case idTarjeta = "id_tarjeta"
        case tipo
        case texto
        case imagenUrl = "imagen_url"
        case ordenLista = "orden_lista"
    }
}

extension Tarjeta {
    static let datosEjemplo = [
        Tarjeta(idTarjeta: 1, tipo: 4, texto: "{\"titulo\":\"wawawawa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "https://www.miau.com.mx/wp-content/uploads/2014/09/gatito.jpg", ordenLista: 1),
        Tarjeta(idTarjeta: 2, tipo: 3, texto: "{\"titulo\":\"wawaawaa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/132.png", ordenLista: 2),
        Tarjeta(idTarjeta: 3, tipo: 2, texto: "{\"titulo\":\"awawawawa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/132.png", ordenLista: 3),
        Tarjeta(idTarjeta: 4, tipo: 1, texto: "{\"titulo\":\"awawawawa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "", ordenLista: 4),
        Tarjeta(idTarjeta: 5, tipo: 2, texto: "{\"titulo\":\"awawawawa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/132.png", ordenLista: 5),
        Tarjeta(idTarjeta: 6, tipo: 3, texto: "{\"titulo\":\"awawawawa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/132.png", ordenLista: 6),
        Tarjeta(idTarjeta: 7, tipo: 1, texto: "{\"titulo\":\"awawawawa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "", ordenLista: 7),
        Tarjeta(idTarjeta: 8, tipo: 2, texto: "{\"titulo\":\"awawawawa\",\"texto\":\"wawawawawa\",\"respuesta1\":\"\",\"respuesta2\":\"\",\"respuesta3\":\"\",\"respuesta4\":\"\",\"correcta\":\"\"}", imagenUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/132.png", ordenLista: 8)
    ]
}

// Extensión para hacer comparable Tarjeta
extension Tarjeta: Equatable {
    static func == (lhs: Tarjeta, rhs: Tarjeta) -> Bool {
        return lhs.idTarjeta == rhs.idTarjeta &&
               lhs.tipo == rhs.tipo &&
               lhs.texto == rhs.texto &&
               lhs.imagenUrl == rhs.imagenUrl &&
               lhs.ordenLista == rhs.ordenLista
    }
}
