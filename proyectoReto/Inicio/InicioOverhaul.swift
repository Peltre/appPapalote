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
    

    init(idZona: Int) {
        _actividadModel = StateObject(wrappedValue: ActividadesViewModel(idZona: idZona))
    }

    var scannerSheet: some View {
        ZStack {
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
            VStack {
                Spacer()
                Text("Apunta la cámara al código QR")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
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
        NavigationView {
            VStack {
                TabView(selection: $selectedIndex) {
                    HomePage()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Inicio")
                        }
                        .tag(0)
                    
                    ContentViewMapas()
                        .tabItem {
                            Image(systemName: "map.fill")
                            Text("Mapa")
                        }
                        .tag(1)
                    
                    // Cambia el contenido de la pestaña QR
                    VStack(spacing: 20) {
                        Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(colorVerde)
                        
                        Text("Escanea un código QR")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Text("Pulsa en el botón de escáner para activar la cámara y escanear un código QR.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Botón para abrir la cámara
                        Button(action: {
                            isPresentingScanner = true
                        }) {
                            Text("Escanear")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(colorVerde)
                                .cornerRadius(10)
                        }
                    }
                    .tabItem {
                        Image(systemName: "qrcode.viewfinder")
                        Text("QR")
                    }
                    .tag(2)
                    
                    ActividadPicker()
                        .tabItem {
                            Image(systemName: "questionmark")
                            Text("Sorprendeme")
                        }
                        .tag(3)
                    
                    Perfil()
                        .tabItem {
                            Image(systemName: "person.circle.fill")
                            Text("Perfil")
                        }
                        .tag(4)
                }
                .onChange(of: selectedIndex) { newValue in
                    if newValue == 2 { // Detecta cuando se selecciona la pestaña de "QR"
                        isPresentingScanner = true
                        print("Se activó el escáner")
                    }
                }
                .sheet(isPresented: $isPresentingScanner) {
                    self.scannerSheet
                }
                .tint(colorVerde)
            }
            .background(
                NavigationLink(
                    destination: TemplateActividad2(unaActividad: actividadEncontrada ?? Actividad2(idActividad: 0, idZona: 0, nombre: "Desconocida", listaTarjetas: Tarjeta.datosEjemplo))
                        .navigationBarHidden(true),
                    isActive: $navegarActividad
                ) {
                    EmptyView()
                }
            )
        }
    }


    private func processScannedCode(_ code: String) {
        if code.starts(with: "actividad:") {
            let components = code.split(separator: ":")
            if let idString = components.last, let id = Int(idString) {
                if let actividad = actividadModel.obtenerActividadPorId(id) {
                    self.actividadEncontrada = actividad
                    self.navegarActividad = true
                    print("Se activo navegar act")
                } else {
                    print("Actividad no encontrada")
                }
            }
        }
    }
}


#Preview {
    InicioOverhaul(idZona: 2)
        .environmentObject(PerfilViewModel())
    // Pasa el idZona correcto según el contexto
}
