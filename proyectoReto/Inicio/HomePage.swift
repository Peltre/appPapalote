//
//  InicioView.swift
//  proyectoReto
//
//  Created by Alumno on 14/11/24.
//

import SwiftUI


struct HomePage: View {
    var colorVerde = Color(red: 190 / 255.0, green: 214 / 255.0, blue: 0 / 255.0)
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(colorVerde)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private let fotos = ["oso", "mariposa 1", "pinguino", "tlacuache", "oso", "oso", "oso"]

    
    @EnvironmentObject var perfilViewModel: PerfilViewModel
    
    var body: some View {
            NavigationView {
            
                VStack {
                    
                    Image(fotos[perfilViewModel.fotoPerfil])
                        .resizable()
                        .scaledToFit()
                        .clipShape(.circle)
                        .frame(width: 100, height: 100)
                        .padding(.top, 20)
                        .shadow(radius: 5)
                    Text("Bienvenid@ \(perfilViewModel.nombreUsuario)")
                        .font(.title3)
                        .bold()
                    
                    NavigationLink(destination: vistaEventos()) {
                        RoundedRectangleCard(text: "Eventos", imageName: "cine")
                        
                    }
                    
                        .padding(.bottom, 40)
                        
                    NavigationLink(destination: vistaNoticias()) {
                        RoundedRectangleCard(text: "Noticias",
                        imageName: "papalotl")
                    }
                    .padding(.bottom, 120)
                }
                .padding()
                .navigationTitle("Inicio")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    perfilViewModel.cargarUsuario()
                }
                
            }
            
        
    }
    
}

struct RoundedRectangleCard: View {
    var text : String
    var imageName : String
    var colorVerde = Color(red: 190 / 255.0, green: 214 / 255.0, blue: 0 / 255.0)

    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(colorVerde)
                .shadow(radius: 5)
            
            VStack {
                Text(text)
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .bold()
                Image(imageName)
                    .resizable()
                
            }
            .padding(5)
        }
        .frame(height: 180)
    }
}

#Preview {
    HomePage()
        .environmentObject(PerfilViewModel())
}
