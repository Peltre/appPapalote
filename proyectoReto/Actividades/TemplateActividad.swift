//
//  TemplateActividad.swift
//  proyectoReto
//
//  Created by Carlos Eugenio Saldaña Tijerina on 17/10/24.
//


//
//  TemplateActividad.swift
//  ViewActividadPapalote
//
//  Created by Alumno on 14/10/24.
//

import SwiftUI



struct TemplateActividad: View {

    var unaActividad: Actividad
    
    // Función que retorna el color basado en el id de la zona
    func getColorForZona(idZona: Int) -> Color {
        switch idZona {
        case 1:
            return colores[1]!
        case 2:
            return colores[2]!
        case 3:  // Para los dos ids de "Pequeños"
            return colores[3]!
        case 4:
            return colores[4]!
        case 8:
            return colores[5]!
        case 9:
            return colores[6]!
        default:
            return Color.gray  // Un color por defecto en caso de que no coincida ningún id
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: Color.yellow.opacity(0.3), location: 0),
                                .init(color: getColorForZona(idZona: unaActividad.id_zona).opacity(0.6), location: 0.5)
                            ]
                        ),
                        startPoint: .init(x: 0, y: 0),
                        endPoint: .init(x: 1, y: 1)
                    ))
                    .mask(LinearGradient(
                        gradient: Gradient(
                            stops: [.init(color: .black, location: 0.4),
                                    .init(color: .black.opacity(0), location: 0.8)]
                        ),
                        startPoint: .init(x: 0, y: 0),
                        endPoint: .init(x: 0.33, y: 1)
                    ))
                    .frame(height: 400)
            }
            .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    ZStack {
                        AsyncImage(url: URL(string: "https://storage.googleapis.com/imagenes_actividades/imagen_actividad_1.jpg")){ image in
                            image.resizable()
                                .aspectRatio(contentMode:.fit)
                        } placeholder: {
                            ProgressView()
                        }
                            
                            .frame(width: 200)
                            .padding(.top, 50)
                    }
                    Text(unaActividad.nombre)
                        .padding()
                        .bold()
                        .font(.largeTitle)
                        .padding()
                        .foregroundColor(getColorForZona(idZona: unaActividad.id_zona))  // Cambia el color del texto
                    ZStack {
                        Text(unaActividad.descripcion)
                            .padding(.horizontal, 80)
                    }
                }
            }
        }
    }
}


#Preview {
    TemplateActividad(unaActividad: Actividad(id_zona: 2, nombre: "VIENTO", descripcion: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin ac ex erat. Vestibulum non scelerisque urna. Aenean vulputate felis et mollis tincidunt. Duis eget rutrum mauris, sed aliquet eros. In hac habitasse platea dictumst.", icono: "" ))
}
