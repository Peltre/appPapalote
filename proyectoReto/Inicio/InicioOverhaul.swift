//
//  InicioOverhaul.swift
//  proyectoReto
//
//  Created by Alumno on 05/11/24.
//
// Holi

import SwiftUI
import CodeScanner

struct InicioOverhaul: View {
    @State var selectedIndex = 0
    @State var isPresentingScanner = false
    @State var scannedCode: String = "Scan a QR"
    @State var navegarActividad: Bool = false
    @State var actividadEncontrada: Actividad2? = nil // Guardar la actividad escaneada

    @StateObject private var actividadModel: ActividadesViewModel
    
    // Inicialización del ViewModel
    init(idZona: Int) {
        _actividadModel = StateObject(wrappedValue: ActividadesViewModel(idZona: idZona))
    }

    var scannerSheet: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    self.isPresentingScanner = false
                    processScannedCode(code.string)
                }
            }
        )
    }

    var colorVerde = Color(red: 190 / 255.0, green: 214 / 255.0, blue: 0 / 255.0)

    let icons = [
        "house.fill",
        "map.fill",
        "plus.app.fill",
        "questionmark",
        "person.circle.fill"
    ]

    var body: some View {
        VStack {
            TabView {
                HomePage()
                    .tabItem() {
                        Image(systemName: "house.fill")
                        Text("Inicio")
                    }
                ContentViewMapas()
                    .tabItem() {
                        Image(systemName: "map.fill")
                        Text("Mapa")
                    }
                vistaEventos()
                    .tabItem() {
                        Image(systemName: "qrcode.viewfinder")
                        Text("QR")
                    }
                vistaEventos()
                    .tabItem() {
                        Image(systemName: "questionmark")
                        Text("Sorprendeme")
                        
                    }
                    
                Perfil()
                    .tabItem() {
                        Image(systemName: "person.circle.fill")
                        Text("Perfil")
                        
                    }
            }.tint(colorVerde)
            .sheet(isPresented: $isPresentingScanner) {
                self.scannerSheet
            }
        }
        .background(
            NavigationLink(
                destination: TemplateActividad2(unaActividad: actividadEncontrada ?? Actividad2(idActividad: 0, idZona: 0, nombre: "Desconocida", listaTarjetas: Tarjeta.datosEjemplo)),
                isActive: $navegarActividad
            ) {
                EmptyView()
            }
        )
    }

    private func processScannedCode(_ code: String) {
        // Verificar si el código QR coincide con el formato esperado para la actividad
        if code.starts(with: "actividad:") {
            let components = code.split(separator: ":")
            if let idString = components.last, let id = Int(idString) {
                // Intentar obtener la actividad por ID usando el ActividadesViewModel
                if let actividad = actividadModel.obtenerActividadPorId(id) {
                    self.actividadEncontrada = actividad
                    self.navegarActividad = true // Activa la navegación
                } else {
                    // Si no se encuentra la actividad, mostrar un error o hacer alguna otra acción
                    print("Actividad no encontrada")
                }
            }
        }
    }
}

#Preview {
    InicioOverhaul(idZona: 2)  // Pasa el idZona correcto según el contexto
}


