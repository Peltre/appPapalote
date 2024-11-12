//
//  InicioOverhaul.swift
//  proyectoReto
//
//  Created by Alumno on 05/11/24.
//

import SwiftUI
import CodeScanner

struct InicioOverhaul: View {
    @State var selectedIndex = 0
    
    @State var isPresentingScanner = false
    @State var scannedCode: String = "Scan a QR"

    var scannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    self.isPresentingScanner = false
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
                        self.isPresentingScanner = true
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
                        .sheet(isPresented: $isPresentingScanner){
                            self.scannerSheet
                        }
                }
            }
            
        }

        }
    }


#Preview {
    InicioOverhaul()
}
