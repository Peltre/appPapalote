//
//  Piso2View.swift
//  PruebaMapas
//
//  Created by Alumno on 14/10/24.
//

import SwiftUI

struct Piso2View: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Color.red
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    Piso2View()
}
