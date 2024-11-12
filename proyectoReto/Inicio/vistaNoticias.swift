//
//  vistaNoticias.swift
//  proyectoReto
//
//  Created by Pedr1p on 05/11/24.
//

import SwiftUI

struct vistaNoticias: View {
    var body: some View {
        // Pasar la URL de la página de Facebook al WebView
        WebView(url: URL(string: "https://www.facebook.com/PapaloteMuseoMty/")!)
            .edgesIgnoringSafeArea(.all)  // Opcional, para mostrar en pantalla completa
    }
}


#Preview {
    vistaNoticias()
}
