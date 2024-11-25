//
// vistaNoticias.swift
// proyectoReto
//
// Created by Pedr1p on 05/11/24.
//

import SwiftUI

struct vistaNoticias: View {
    @Environment(\.presentationMode) var presentationMode // Ambiente para controlar la navegación

    var body: some View {
        WebView(url: URL(string: "https://www.facebook.com/PapaloteMuseoMty/")!)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("Noticias", displayMode: .inline)
            .navigationBarBackButtonHidden(true) // Esconde el botón de retroceso predeterminado
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss() // Cierra la vista y regresa
            }) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25)
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color(white: 1))
                    .clipShape(Circle())
                    .shadow(radius: 3, y: 2)
                    .foregroundColor(.blue)
            })
    }
}

#Preview {
    vistaNoticias()
}
