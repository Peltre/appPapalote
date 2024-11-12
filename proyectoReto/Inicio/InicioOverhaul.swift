//
//  InicioOverhaul.swift
//  proyectoReto
//
//  Created by Alumno on 05/11/24.
//

import SwiftUI

struct InicioOverhaul: View {
    @State var selectedIndex = 0
    
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
            
            ZStack {
                switch selectedIndex {
                case 0:
                    NavigationView {
                        Text("")
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Text("Inicio")
                                        .foregroundColor(.white)
                                        .bold()
                                        .font(.system(size: 35))
                                }
                                ToolbarItem(placement: .topBarTrailing) {
                                    Image("logoBlanco")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                }
                            }
                            .frame(maxHeight: .infinity)
                            .toolbarBackground(colorVerde, for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                    }
                default:
                    NavigationView {
                        VStack {
                            Text("Pantalla de Inicio")
                        }
                        .navigationTitle("Inicio")
                    }
                }
                
            }
            Spacer()
            Divider()
            HStack() {
                ForEach(0..<5, id:\.self ) { number in
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        if (icons[number] == "plus.app.fill") {
                          Image(systemName: icons[number])
                            .font(.system(size: 45,
                                          weight: .regular,
                                          design: .default))
                            .foregroundColor(colorVerde)
                        } else {
                            Image(systemName: icons[number])
                                .font(.system(size: 25,
                                              weight: .regular,
                                              design: .default))
                                .foregroundColor(colorVerde)
                        }
                    })
                    Spacer()
                }
            }
            
        }

        }
    }


#Preview {
    InicioOverhaul()
}
