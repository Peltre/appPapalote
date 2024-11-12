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
    @State private var isLoading = false
    
    init() {
        _ = ActividadesDataManager.shared
        // Necesitamos usar _usuario para modificar el State directamente en init
        _usuario = State(initialValue: cargarUsuarioInicial())
    }
    
    var body: some Scene {
        WindowGroup {
            if usuario != nil {
                InicioView()
            } else {
                SignIn()
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
            loadActividadesCompletadas(for: usuarioCargado.idUsuario)
            usuarioGlobal = usuarioCargado
            return usuarioCargado
        } catch {
            print("Error cargando usuario: \(error)")
            return nil
        }
    }
    
    // Función para cargar actividades completadas
    private func loadActividadesCompletadas(for idUsuario: Int) {
        guard !isLoading else { return } // Evitar múltiples cargas
        isLoading = true
        
        obtenerActividadesCompletadas(idUsuario: idUsuario) { completadas in
            actividadesCompletadas = completadas
            isLoading = false // Cambiar el estado de carga a false después de obtener los datos
        }
    }
    
}
