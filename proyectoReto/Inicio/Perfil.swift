//
//  Perfil.swift
//  proyectoReto
//
//  Created by user254414 on 10/28/24.
//

import SwiftUI

struct Perfil: View {
    
    @State private var fotoPerfil: String = "quincy"
    @Environment(\.presentationMode) var presentationMode
    @State private var navegarASignIn = false
    @State private var isEditing: Bool = false
    @State private var isView: Bool = false
    
    private let fotos = ["quincy", "obyn", "si", "jason", "pat"]
    
    var body: some View {
        NavigationStack {
            VStack {
                // Botón de regreso y título de perfil
                HStack {
                    Spacer()
                    ZStack {
                        Text("Perfil")
                            .font(.title)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
                
                // Imagen de perfil y botón de editar
                VStack {
                    Image(fotoPerfil)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .padding()
                    
                    Text("Quincy")
                        .font(.largeTitle)
                        .bold()
                    ZStack {
                        Button {
                            withAnimation {
                                isEditing = true // Activa el overlay al presionar el botón
                            }
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 50))
                                .foregroundColor(.accentColor)
                            
                        }
                    }
                    .offset(x: 60, y: -110)
                }
                
                // Sección de insignias
                Form {
                    Section(header: Text("Insignias")) {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<5) { _ in
                                    Button {
                                        isView = true
                                    } label: {
                                        Image("medalla")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            //.grayscale(0.99999)
                                    }
                                }
                                }
                            }
                        }
                    }
                    .shadow(radius: 7)
                    
                    // Cerrar sesión
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        Button {
                            borrarUsuario()
                            navegarASignIn = true
                        } label: {
                            Text("Cerrar Sesion")
                        }
                    }
                    .padding()
                    .navigationDestination(isPresented: $navegarASignIn) {
                        SignIn()
                    }
                }
                // Overlay de selección de imágenes
                .overlay(
                    Group {
                        if isEditing {
                            Color.black.opacity(0.4) // Fondo oscuro para enfocar la vista emergente
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation {
                                        isEditing = false // Cerrar al hacer clic fuera
                                    }
                                }
                            
                            VStack {
                                Text("Selecciona una imagen")
                                    .font(.headline)
                                    .padding()
                                
                                ScrollView(.horizontal) {
                                    HStack(spacing: 20) {
                                        ForEach(fotos, id: \.self) { imageName in
                                            Button {
                                                fotoPerfil = imageName
                                                withAnimation {
                                                    isEditing = false
                                                }
                                            } label: {
                                                Image(imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                                    .padding(8)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 4)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                                
                                Button("Cancelar") {
                                    withAnimation {
                                        isEditing = false
                                    }
                                }
                                .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding()
                            .transition(.move(edge: .bottom))
            
                        }
                        
                        else if isView {
                            Color.black.opacity(0.4) // Fondo oscuro para enfocar la vista emergente
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation {
                                        isView = false // Cerrar al hacer clic fuera
                                    }
                                }
                            VStack {
                                Text("Medalla #1")
                                    .font(.title)
                                    .bold()
                                Text("Visita 5 zonas para desbloquear esta insignia")
                                
                                Image("medalla")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .grayscale(0.99)
                                
                                Button("Cancelar") {
                                    withAnimation {
                                        isView = false
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding()
                            .transition(.move(edge: .bottom))
                        }
                    }
                )
            }
        }
    }


#Preview {
    Perfil()
}

func borrarUsuario() {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json")
    
    guard let url = fileURL else { return }
    
    do {
        // Guardamos un JSON vacío
        try "{}".write(to: url, atomically: true, encoding: .utf8)
        print("El archivo de sesión ha sido limpiado.")
    } catch {
        print("Error al intentar limpiar el archivo de sesión: \(error.localizedDescription)")
    }
}
