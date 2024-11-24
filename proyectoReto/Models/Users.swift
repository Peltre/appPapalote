//
//  Users.swift
//  proyectoReto
//
//  Created by Alumno on 28/10/24.
//

import Foundation

struct user: Codable {
    var idUsuario: Int
    var username: String
    var correo : String
    var pfp: Int

    // CodingKeys para mapear las propiedades al JSON
    enum CodingKeys: String, CodingKey {
        case idUsuario = "id_usuario"
        case username = "username"
        case correo = "correo"
        case pfp = "pfp"
    }
}
