//
//  ContentView.swift
//  proyectoReto
//
//  Created by Pedr1p on 12/10/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var zonaData = ZonasData2()
    @Environment(\.dismiss) private var dismiss
    @State private var listaCompletados: [Bool] = []
    @State private var isDataLoaded = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with ultra-thin material effect
                Color.clear.background(.ultraThinMaterial).ignoresSafeArea()
                
                VStack {
                    ZStack {
                        Text("Medallas")
                            .font(.system(size: 31))
                            .fontWeight(.black)
                            .padding()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25)
                                .foregroundColor(.white)
                                .bold()
                                .padding(10)
                                .background(Color(white: 0.3))
                                .clipShape(Circle())
                        }
                        .offset(x: -UIScreen.main.bounds.width/2 + 35)
                    }
                    Divider()
                    
                    if isDataLoaded {
                        // Display medals in rows with two items per row
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(0..<zonaData.zonas.count / 2, id: \.self) { rowIndex in
                                    HStack(spacing: -15) {
                                        // Left item in row
                                        medalla(zona: zonaData.zonas[rowIndex * 2], listaCompletados: self.listaCompletados)
                                        
                                        // Right item in row, if it exists
                                        if rowIndex * 2 + 1 < zonaData.zonas.count {
                                            medalla(zona: zonaData.zonas[rowIndex * 2 + 1], listaCompletados: self.listaCompletados)
                                        }
                                    }
                                }
                                
                                // Handle an odd number of zones by adding a final row with a single item
                                if zonaData.zonas.count % 2 != 0 {
                                    HStack {
                                        medalla(zona: zonaData.zonas.last!, listaCompletados: self.listaCompletados)
                                        Spacer() // to align the single item to the left
                                    }
                                }
                            }
                            .padding(5)
                        }
                    } else {
                        // Show a loading indicator while waiting for data
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                    }
                }
                .onAppear {
                    zonaData.obtenerListaZonasCompletadas { completadas in
                        listaCompletados = completadas ?? Array(repeating: false, count: zonaData.zonas.count)
                        isDataLoaded = true
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ContentView()
}

struct medalla: View {
    var zona: Zona3
    var listaCompletados : [Bool]
    var body: some View {
        ZStack {
            // Background card with rounded corners and ultra-thin material
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(width: 200, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(listaCompletados[zona.id-1] ? Color.yellow : Color.clear, lineWidth: 4)
                )
            
            VStack {
                Text(zona.nombre)
                    .font(.system(size: 30))
                    .foregroundStyle(colores[zona.id]!)
                    .bold()
                    .padding(.top, 5)
                
                // Medal image with border overlay for completion status
                Image(iconosZonas[zona.id] ?? "cat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y: -10)
            }
        }
        .scaleEffect(0.9)
    }
}

