//
//  Users.swift
//  proyectoReto
//
//  Created by Alumno on 28/10/24.
//

import Foundation

struct user: Codable {
    let idUsuario: Int
    var username: String
    let correo : String
    var pfp: Int

    // CodingKeys para mapear las propiedades al JSON
    enum CodingKeys: String, CodingKey {
        case idUsuario = "id_usuario"
        case username = "username"
        case correo = "correo"
        case pfp = "pfp"
    }
}
