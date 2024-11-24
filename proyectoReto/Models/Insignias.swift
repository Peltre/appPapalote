//
//  Insignias.swift
//  proyectoReto
//
//  Created by user273350 on 11/22/24.
//

import Foundation

struct Insignia: Codable {
    var InsigniaId: Int
    var ImagenLink: String
    var Nombre : String
    var Descripcion : String
    var Valor: Int

    // CodingKeys para mapear las propiedades al JSON
    enum CodingKeys: String, CodingKey {
        case InsigniaId = "InsigniaID"
        case ImagenLink = "ImagenLink"
        case Nombre = "Nombre"
        case Descripcion = "Descripcion"
        case Valor = "Valor"
    }
}

struct UserInsignia : Codable {
    var UserID : Int
    var InsigniaID : Int
    var FechaCompletado : String
    
    // CodingKeys para mapear las propiedades al JSON
    enum CodingKeys: String, CodingKey {
        case UserID = "UserID"
        case InsigniaID = "InsigniaID"
        case FechaCompletado = "FechaCompletado"
    }
}
