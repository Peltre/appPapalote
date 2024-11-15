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
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            Text("")
                .navigationTitle("Inicio")
        }
    }
}

#Preview {
    HomePage()
}
