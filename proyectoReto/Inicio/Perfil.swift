    import SwiftUI

    struct Perfil: View {
        @EnvironmentObject var perfilViewModel: PerfilViewModel
        @State private var fotoPerfil: Int = 0
        @Environment(\.presentationMode) var presentationMode
        @State private var navegarASignIn = false
        @State private var isEditing: Bool = false // Para la edición de la foto
        @State private var isView: Bool = false // Para la vista de insignias
        @State private var editingName: Bool = false // Para la edición del nombre
        
        private let fotos = ["oso", "mariposa 1", "pinguino", "tlacuache", "tlacuache", "oso", "oso"]
        
        var body: some View {
            NavigationStack {
                VStack {
                    // Botón de regreso y título de perfil
                    HStack {
                        Spacer()
                        ZStack {
                            Text("Perfil")
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                    
                    // Imagen de perfil y botón de editar
                    VStack {
                        Image(fotos[perfilViewModel.fotoPerfil])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .padding()
                        
                        // Nombre del usuario con botón de edición
                        HStack {
                            if editingName {
                                TextField("Nombre", text: $perfilViewModel.nombreUsuario, onCommit: {
                                    editingName = false
                                })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 200)
                                // add call to endpoint to change username
                            } else {
                                Text(perfilViewModel.nombreUsuario)
                                    .font(.largeTitle)
                                    .bold()
                            }
                            
                            Button {
                                if editingName == true {
                                    perfilViewModel.actualizarUsuario { success in
                                        if success {
                                        
                                            print("Nombre actualizado papu")
                                        }
                                    }
                                }
                                
                                withAnimation {
                                    editingName.toggle()
                                }
                            } label: {
                                Image(systemName: editingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        // Botón para editar la foto
                        ZStack {
                            Button {
                                withAnimation {
                                    isEditing = true // Activa el overlay al presionar el botón
                                }
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 50))
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .offset(x: 60, y: -110)
                    }
                    
                    // Sección de insignias
                    Form {
                        Section(header: Text("Insignias")) {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(0..<5) { _ in
                                        Button {
                                            isView = true
                                        } label: {
                                            Image("medalla")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 100)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .shadow(radius: 7)
                    
                    // Cerrar sesión
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        Button {
                            borrarUsuario()
                            navegarASignIn = true
                        } label: {
                            Text("Cerrar Sesión")
                        }
                    }
                    .padding()
                    .navigationDestination(isPresented: $navegarASignIn) {
                        SignIn()
                    }
                }
                .onAppear {
                    perfilViewModel.cargarUsuario()
                }
                
                // Overlay de edición de la foto o vista de insignias
                .overlay(
                    Group {
                        if isEditing {
                            Color.black.opacity(0.4) // Fondo oscuro para enfocar la vista emergente
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation {
                                        isEditing = false // Cerrar al hacer clic fuera
                                    }
                                }
                            
                            VStack {
                                Text("Selecciona una imagen")
                                    .font(.headline)
                                    .padding()
                                
                                ScrollView(.horizontal) {
                                    HStack(spacing: 20) {
                                        // something funny happening here please fix pedro
                                        ForEach(Array(fotos.enumerated()), id: \.0) { index, imageName in
                                            Button{
                                                perfilViewModel.fotoPerfil = index
                                                withAnimation {
                                                    isEditing = false
                                                }
                                            } label: {
                                                Image(imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                                    .padding(8)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 4)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                                
                                Button("Cancelar") {
                                    withAnimation {
                                        isEditing = false
                                    }
                                }
                                .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding()
                            .transition(.move(edge: .bottom))
                        } else if isView {
                            Color.black.opacity(0.4) // Fondo oscuro para enfocar la vista emergente
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation {
                                        isView = false // Cerrar al hacer clic fuera
                                    }
                                }
                            VStack {
                                Text("Medalla #1")
                                    .font(.title)
                                    .bold()
                                Text("Visita 5 zonas para desbloquear esta insignia")
                                
                                Image("medalla")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .grayscale(0.99)
                                
                                Button("Cancelar") {
                                    withAnimation {
                                        isView = false
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding()
                            .transition(.move(edge: .bottom))
                        }
                    }
                )
            }
        }
    }

    #Preview {
        Perfil()
            .environmentObject(PerfilViewModel())
    }

    // ViewModel que controla los datos del perfil
    class PerfilViewModel: ObservableObject {
        @Published var fotoPerfil: Int = 0 // Valor inicial
        @Published var nombreUsuario: String = "Quincy" // Nombre editable
        
        init() {
            cargarUsuario()
        }
    
    // Load user data from file
    func cargarUsuario() {
        // Get the URL of the file where user data is saved
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json") else {
            print("Error: No se pudo obtener la URL del archivo de sesión")
            return
        }
        
        // Try to load the data
        do {
            let data = try Data(contentsOf: fileURL)
            let usuario = try JSONDecoder().decode(user.self, from: data)
            
            // Update the properties with the loaded user data
            DispatchQueue.main.async {
                self.fotoPerfil = usuario.pfp - 1
                self.nombreUsuario = usuario.username
            }
            
        } catch {
            print("Error al cargar los datos del usuario: \(error)")
        }
        
    }
        
        func cargarUsername() {
            guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json") else {
                print("Error: No se pudo obtener la URL del archivo de sesión")
                return
            }
            
            // Try to load the data
            do {
                let data = try Data(contentsOf: fileURL)
                let usuario = try JSONDecoder().decode(user.self, from: data)
                
                // Update the properties with the loaded user data
                DispatchQueue.main.async {
                    self.nombreUsuario = usuario.username
                }
                
            } catch {
                print("Error al cargar los datos del usuario: \(error)")
            }
        }
        
        func actualizarUsuario(completition: @escaping (Bool) -> Void) {
            guard let url = URL(string: "https://r1aguilar.pythonanywhere.com/modificar_usuario") else {
                print("URL Inválida")
                completition(false)
                return
            }
            
            guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json"),
                  let data = try? Data(contentsOf: fileURL),
                  let usuario = try? JSONDecoder().decode(user.self, from: data) else {
                print("Error cargando el usuario actual")
                completition(false)
                return
            }
            
            // Crear el diccionario solo con los campos necesarios
            let datosActualizados: [String: Any] = [
                "id": usuario.idUsuario,
                "username": nombreUsuario,  // nuevo nombre de usuario
                "pfp": fotoPerfil + 1        // pfp sin cambios
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: datosActualizados) else {
                print("Error al serializar los datos")
                completition(false)
                return
            }
            
            print("JSON enviado al servidor:", String(data: jsonData, encoding: .utf8) ?? "Error al convertir JSON a string")
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error en la solicitud: \(error.localizedDescription)")
                    completition(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Respuesta del servidor no válida")
                    completition(false)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("Datos actualizados correctamente")
                    completition(true)
                } else {
                    print("Error del servidor: \(httpResponse.statusCode)")
                    if let data = data {
                        print("Respuesta del servidor:", String(data: data, encoding: .utf8) ?? "No se pudo leer la respuesta")
                    }
                    completition(false)
                }
            }.resume()
        }
}


    // Función para borrar el usuario
    func borrarUsuario() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json")
        
        guard let url = fileURL else { return }
        
        do {
            // Guardamos un JSON vacío
            try "{}".write(to: url, atomically: true, encoding: .utf8)
            print("El archivo de sesión ha sido limpiado.")
        } catch {
            print("Error al intentar limpiar el archivo de sesión: \(error.localizedDescription)")
        }
    }
