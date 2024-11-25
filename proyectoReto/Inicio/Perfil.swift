import SwiftUI
import Network

struct Perfil: View {
    @EnvironmentObject var perfilViewModel: PerfilViewModel
    @State private var fotoPerfil: Int = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var navegarASignIn = false
    @State private var isEditing: Bool = false // Para la edición de la foto
    @State private var isView: Bool = false // Para la vista de insignias
    @State private var editingName: Bool = false // Para la edición del nombre
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false // Estado para mostrar alerta
    @State var insigniasSetLocal : Set<Int> = Set<Int>()
    @State private var mostrarSheet = false
    @State private var insigniaSeleccionada: Insignia? = nil

    
    private let fotos = ["pfp_1", "pfp_2", "pfp_3", "pfp_4", "pfp_5"]
    
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
                                    
                                    if perfilViewModel.nombreUsuario.count > 10 {
                                        alertMessage = "El nombre no puede tener más de 10 caracteres."
                                        showAlert = true
                                        return
                                    }
                                    
                                    if perfilViewModel.nombreUsuario.count < 2 {
                                        alertMessage = "El nombre tiene que tener al menos 2 caracteres."
                                        showAlert = true
                                        return
                                    }
                                    
                                    perfilViewModel.guardarUsuarioLocalmente()
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
                                ForEach(insignias, id: \.InsigniaId) { insignia in
                                    VStack {
                                        if let url = URL(string: insignia.ImagenLink) {
                                            CacheAsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 100, height: 100)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 100, height: 100)
                                                        .shadow(radius: 4)
                                                        .grayscale(insigniasCompletadasSet.contains(insignia.InsigniaId) ? 0 : 0.99)
                                                case .failure:
                                                    Image(systemName: "medalla")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 100, height: 100)
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        } else {
                                            Image(systemName: "medalla")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 100)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text(insignia.Nombre)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                    .onTapGesture {
                                        insigniaSeleccionada = insignia  // Asignar la insignia seleccionada
                                        mostrarSheet.toggle()           // Mostrar la sheet
                                    }                               
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $mostrarSheet) {
                            if let insignia = insigniaSeleccionada {
                                VStack {
                                    Text(insignia.Nombre)
                                        .font(.title)
                                        .bold
                                        .padding()
                                    Text(insignia.Descripcion)
                                        .font(.body)
                                        .padding()
                                    Button("Cerrar") {
                                        mostrarSheet.toggle() // Cerrar la sheet
                                    }
                                    .padding()
                                }
                                .padding()
                            }
                }
                .shadow(radius: 7)
                .onAppear{
                    print("Imprimiendo el set de Insignias Completadas \(insigniasCompletadasSet)")
                }

                
                // Cerrar sesión
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    
                    Button {
                        self.cerrarSesion(usuario: usuarioGlobal!)
                    } label: {
                        Text("Cerrar Sesión")
                    }
                }
                .padding()
                .fullScreenCover(isPresented: $navegarASignIn) {
                    SignIn()
                }
            }
            .onAppear {
                perfilViewModel.cargarUsuario()
            }
            .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
                                            perfilViewModel.guardarUsuarioLocalmente()
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

func borrarArchivos() {
    // Lista de nombres de archivos a borrar
    let archivos = [
        "sesion.json",
        "insigniasCompletadas.json",
        "actividadesCompletadas.json"
    ]
    
    // Obtener el directorio de documentos
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("No se pudo acceder al directorio de documentos")
        return
    }
    
    // Iterar sobre cada archivo y borrarlo
    for archivo in archivos {
        let fileURL = documentDirectory.appendingPathComponent(archivo)
        
        do {
            // Verificar si el archivo existe
            if FileManager.default.fileExists(atPath: fileURL.path) {
                // Intentar primero sobrescribir con JSON vacío
                try "{}".write(to: fileURL, atomically: true, encoding: .utf8)
                print("El archivo \(archivo) ha sido limpiado.")
            } else {
                print("El archivo \(archivo) no existe.")
            }
        } catch {
            print("Error al intentar limpiar el archivo \(archivo): \(error.localizedDescription)")
        }
    }
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
    
    func cargarFoto() {
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
            }
            
        } catch {
            print("Error al cargar los datos del usuario: \(error)")
        }
    }
    
    
    func guardarUsuarioLocalmente() {
        // Obtener la URL del archivo
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json") else {
            print("Error: No se pudo obtener la URL del archivo de sesión")
            return
        }
        
        // Intentar cargar los datos existentes
        var usuarioActualizado: user
        do {
            let data = try Data(contentsOf: fileURL)
            usuarioActualizado = try JSONDecoder().decode(user.self, from: data)
            
            // Actualizar solo las propiedades necesarias
            usuarioActualizado.username = nombreUsuario
            usuarioActualizado.pfp = fotoPerfil + 1// Actualiza según corresponda
        } catch {
            print("No se pudieron cargar los datos existentes o archivo no encontrado. Se creará un nuevo usuario.")
            // Si no hay datos existentes, crear un nuevo usuario con valores por defecto
            usuarioActualizado = user(idUsuario: 1, username: nombreUsuario, correo: "hola@gmail.com", pfp: fotoPerfil+1) // Ajusta los valores predeterminados
        }
        
        // Guardar los datos actualizados
        do {
            let updatedData = try JSONEncoder().encode(usuarioActualizado)
            try updatedData.write(to: fileURL)
            print("Usuario actualizado guardado localmente.")
            usuarioGlobal!.pfp = fotoPerfil + 1
            usuarioGlobal!.username = nombreUsuario
        } catch {
            print("Error al guardar los datos localmente: \(error)")
        }
    }

    
    func actualizarUsuario(completition: @escaping (Bool) -> Void) {
        guard let url = URL(string: apiURLbase + "modificar_usuario") else {
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
            "pfp": fotoPerfil + 1       // pfp sin cambios
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
                DispatchQueue.main.async {
                    self.guardarUsuarioLocalmente()
                }
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

extension Perfil {
    func cerrarSesion(usuario: user) {
        // Primero verificamos la conexión con el endpoint
        let url = URL(string: apiURLbase + "testConnection")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Verificar si hay error o no hay datos
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.mostrarAlertaNoConexion()
                }
                return
            }
            
            // Intentar decodificar la respuesta
            do {
                struct ServerResponse: Codable {
                    let mensaje: String
                }
                
                let response = try JSONDecoder().decode(ServerResponse.self, from: data)
                
                // Verificar si el mensaje es el esperado
                guard response.mensaje == "Servidor esta vivo" else {
                    DispatchQueue.main.async {
                        self.mostrarAlertaNoConexion()
                    }
                    return
                }
                
                // Si llegamos aquí, la conexión está bien y podemos proceder
                DispatchQueue.main.async {
                    // Grupo de dispatch para manejar múltiples operaciones asíncronas
                    let group = DispatchGroup()
                    
                    // Primera operación
                    group.enter()
                    actualizarUsuarioDB(usuario: usuario) { resultado in
                        // Asumiendo que actualizarUsuarioDB tiene un completion handler
                        group.leave()
                    }
                    
                    // Segunda operación
                    group.enter()
                    fetchInsigniasCompletadas(idUsuario: usuario.idUsuario) { resultado in
                        // Asumiendo que fetchInsigniasCompletadas tiene un completion handler
                        group.leave()
                    }
                    
                    // Tercera operación
                    group.enter()
                    obtenerActividadesCompletadas2(idUsuario: usuario.idUsuario) { completadas in
                        actividadesCompletadas = completadas
                        group.leave()
                    }
                    
                    // Cuando todas las operaciones terminen, ejecutar borrarArchivos
                    group.notify(queue: .main) {
                        borrarArchivos()
                        navegarASignIn = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.mostrarAlertaNoConexion()
                }
            }
        }.resume()
    }
    
    // Función auxiliar para mostrar alerta de no conexión
    private func mostrarAlertaNoConexion() {
        let alerta = UIAlertController(
            title: "Sin conexión",
            message: "No hay conexión a internet. Por favor verifica tu conexión e intenta nuevamente.",
            preferredStyle: .alert
        )
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(alerta, animated: true)
        }
    }
}
