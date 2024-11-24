import SwiftUI

struct ActividadPicker: View {
    @State private var areaSeleccionada: AreaConocimiento = .naturaleza
    @State private var tiempoMaximo: Double = 60
    @State private var tipoParticipacion: TipoParticipacion = .ambos

    var criteriosFiltrados: [Actividad2] {
        Actividad2.datosEjemplo.filter { actividad in
            actividad.areaConocimiento == areaSeleccionada &&
            actividad.tiempoEstimado <= Int(tiempoMaximo) &&
            (actividad.tipoParticipacion == tipoParticipacion || tipoParticipacion == .ambos)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 10) { // Reduce el espacio entre contenedores
                // Área de Conocimiento
                GroupBox(label: Text("Área de Conocimiento").font(.headline)) {
                    Picker("Área de Conocimiento", selection: $areaSeleccionada) {
                        ForEach(AreaConocimiento.allCases, id: \.self) { area in
                            Text(area.rawValue)
                                .tag(area)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.top, 20) // Padding entre el techo y el primer contenedor

                // Tiempo Máximo
                GroupBox(label: Text("Tiempo máximo").font(.headline)) {
                    VStack(spacing: 5) { // Reduce espacio interno
                        Text("Selecciona tiempo: \(Int(tiempoMaximo)) minutos")
                        Slider(value: $tiempoMaximo, in: 10...60, step: 10)
                    }
                }

                // Tipo de Participación
                GroupBox(label: Text("Tipo de Participación").font(.headline)) {
                    Picker("Tipo de Participación", selection: $tipoParticipacion) {
                        ForEach(TipoParticipacion.allCases, id: \.self) { tipo in
                            Text(tipo.rawValue.capitalized)
                                .tag(tipo)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Lista de Actividades
                GroupBox(label: Text("Actividades encontradas: \(criteriosFiltrados.count)").font(.headline)) {
                    List(criteriosFiltrados) { actividad in
                        VStack(alignment: .leading, spacing: 5) { // Reduce espacio entre textos
                            Text(actividad.nombre)
                                .font(.headline)
                            Text("Área: \(actividad.areaConocimiento.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Tiempo estimado: \(actividad.tiempoEstimado) minutos")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Tipo: \(actividad.tipoParticipacion.rawValue.capitalized)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxHeight: .infinity) // Permite que la lista ocupe más espacio
                }
            }
            .padding(.horizontal) // Espaciado horizontal único para toda la vista
            .navigationTitle("Filtrar Actividades")
        }
    }
}

// Extensiones y datos ya proporcionados
enum AreaConocimiento: String, CaseIterable, Codable {
    case naturaleza = "Naturaleza"
    case tecnología = "Tecnología"
    case arte = "Arte"
    case deportes = "Deportes"
}

enum TipoParticipacion: String, CaseIterable, Codable {
    case individual = "Individual"
    case grupal = "Grupal"
    case ambos = "Ambos"
}

extension Actividad2 {
    var areaConocimiento: AreaConocimiento {
        switch idZona {
        case 1, 2: return .naturaleza
        case 3, 4: return .tecnología
        case 5: return .arte
        case 6: return .deportes
        default: return .naturaleza
        }
    }

    var tiempoEstimado: Int {
        return idActividad * 10
    }

    var tipoParticipacion: TipoParticipacion {
        return idActividad % 2 == 0 ? .grupal : .individual
    }
}

struct ActividadPicker_Previews: PreviewProvider {
    static var previews: some View {
        ActividadPicker()
    }
}
