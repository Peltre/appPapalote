import SwiftUI

struct SignIn: View {
    @State private var username: String = ""
    @State private var correo: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoginViewShown: Bool = false
    @State private var isRegisterViewShown: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false // Nuevo estado para el progreso
    @State private var isAuthenticated: Bool = false // Nueva variable de autenticación
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isSignInButtonDisabled: Bool {
        [correo, password].contains(where: \.isEmpty) || isLoading // Deshabilitar si está cargando
    }
    
    var isRegisterButtonDisabled: Bool {
        [correo, password, username].contains(where: \.isEmpty)
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.init(red: 193/255, green: 214/255, blue: 47/255).ignoresSafeArea()
                
                VStack {
                    Image("LogoVerde")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 350)
                        .offset(x: -4)
                        .padding(.bottom, 30)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            isLoginViewShown = true
                        }
                    } label: {
                        Text("Comenzar")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(height: 50)
                    .frame(width: 280)
                    .background(
                        LinearGradient(colors: [colores[3]!, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(30)
                    .shadow(radius: 8, y: 10)
                    .padding()
                }
                
                if isLoginViewShown {
                    loginView
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        .zIndex(isRegisterViewShown ? 0 : 1)
                }
                
                if isRegisterViewShown {
                    registerView
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        .zIndex(isRegisterViewShown ? 1 : 0)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("Aceptar")))
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isAuthenticated) {
                InicioView() // Navega a InicioView cuando isAuthenticated es true
            }
        }
    }
    
    private var loginView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .padding(.vertical, UIScreen.screenHeight / 6)
                .padding(.horizontal, 25)
                .shadow(radius: 8, y: 10)
                .environment(\.colorScheme, .light)
            
            VStack {
                Text("Inicio de sesión")
                    .font(.system(size: 40))
                    .bold()
                    .padding(.bottom, 25)
                    .foregroundStyle(Color.black)
                
                TextField("Correo", text: $correo, prompt: Text("Ingresa tu correo").foregroundColor(Color(white: 0.4)).bold())
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 2)
                    }
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.9)))
                    .shadow(radius: 2, y: 2)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .frame(width: 335)
                
                passwordField
                
                Button {
                    iniciarSesion()
                } label: {
                    if isLoading {
                        ProgressView() // Ícono de carga
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 20, height: 20) // Tamaño del ícono
                    } else {
                        Text("Ingresar")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 50)
                .frame(width: 280)
                .background(
                    isSignInButtonDisabled ?
                    LinearGradient(colors: [Color(white: 0.75), Color(white: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [colores[3]!, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(30)
                .shadow(radius: 8, y: 10)
                .padding(.top, 40)
                .disabled(isSignInButtonDisabled) // Deshabilitar el botón si está cargando
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLoginViewShown = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isRegisterViewShown = true
                            }
                        }
                    }
                } label: {
                    Text("¿No tienes una cuenta?").padding(.top, 10)
                }
            }
            
            closeButton {
                withAnimation(.easeInOut) {
                    isLoginViewShown = false
                }
            }
        }
    }

    private var registerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .padding(.vertical, UIScreen.screenHeight/6)
                .padding(.horizontal, 25)
                .shadow(radius: 8, y: 10)
                .environment(\.colorScheme, .light)
            
            VStack {
                Text("Registro de usuario")
                    .font(.system(size: 37))
                    .bold()
                    .padding(.bottom, 25)
                    .foregroundStyle(Color.black)
                
                TextField("Correo", text: $correo, prompt: Text("Ingresa tu correo").foregroundColor(Color(white: 0.4)).bold())
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 2)
                    }
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.9)))
                    .shadow(radius: 2, y: 2)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    .frame(width: 335)
                
                TextField("Nombre de usuario", text: $username, prompt: Text("Nombre de usuario").foregroundColor(Color(white: 0.4)).bold())
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 2)
                    }
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.9)))
                    .shadow(radius: 2, y: 2)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .frame(width: 335)
                
                passwordField
                
                Button {
                    print("Registrarse")
                } label: {
                    Text("Regístrate")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .frame(width: 280)
                .background(
                    isRegisterButtonDisabled ?
                    LinearGradient(colors: [Color(white: 0.75), Color(white: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [colores[3]!, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(30)
                .shadow(radius: 8, y: 10)
                .padding(.top, 40)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRegisterViewShown = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isLoginViewShown = true
                            }
                        }
                    }
                } label: {
                    Text("¿Ya tienes una cuenta?").padding(.top, 10)
                }
            }
            
            closeButton {
                withAnimation(.easeInOut) {
                    isRegisterViewShown = false
                }
            }
        }
    }
    
    private func iniciarSesion() {
        isLoading = true // Comenzar la carga
        
        guard let url = URL(string: "\(apiURLbase)login") else { return }
        
        let loginData: [String: String] = ["correo": correo, "password": password]
        guard let jsonData = try? JSONEncoder().encode(loginData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false // Detener la carga
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "No se pudo ingresar: \(error.localizedDescription)"
                    self.showAlert = true
                    self.correo = ""
                    self.password = ""
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "No se recibió datos de la respuesta."
                    self.showAlert = true
                    self.correo = ""
                    self.password = ""
                }
                return
            }
            
            if let usuario = try? JSONDecoder().decode(user.self, from: data) {
                guardarUsuario(usuario: usuario)
                usuarioGlobal = usuario
//                verificarActividadesCompletadas()
                obtenerActividadesCompletadas(idUsuario: usuario.idUsuario) { completadas in
                    actividadesCompletadas = completadas
                }
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "No se pudo ingresar: datos inválidos."
                    self.showAlert = true
                    self.correo = ""
                    self.password = ""
                }
            }
        }
        
        task.resume()
    }
    
    private func guardarUsuario(usuario: user) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("sesion.json")
        
        guard let url = fileURL else {
            print("Error: No se pudo crear la URL del archivo")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Para mejor legibilidad del JSON
            let jsonData = try encoder.encode(usuario)
            
            // Intentamos convertir el JSON a String para verificar su contenido
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON a guardar: \(jsonString)")
            }
            
            try jsonData.write(to: url)
            
            // Verificamos que el archivo se haya creado
            if FileManager.default.fileExists(atPath: url.path) {
                // Leemos el archivo inmediatamente para verificar
                let savedData = try Data(contentsOf: url)
                if let savedString = String(data: savedData, encoding: .utf8) {
                    print("Contenido guardado en el archivo: \(savedString)")
                }
                
                // Intentamos decodificar inmediatamente para verificar
                let decoder = JSONDecoder()
                if let savedUser = try? decoder.decode(user.self, from: savedData) {
                    print("Verificación: Usuario guardado y decodificado correctamente")
                    print("Usuario guardado: \(savedUser)")
                } else {
                    print("Error: No se pudo decodificar el usuario después de guardarlo")
                }
            } else {
                print("Error: El archivo no se creó correctamente")
            }
        } catch {
            print("Error detallado guardando el usuario: \(error)")
            if let encodingError = error as? EncodingError {
                switch encodingError {
                case .invalidValue(let value, let context):
                    print("Valor inválido: \(value)")
                    print("Contexto del error: \(context.debugDescription)")
                    print("Ruta de codificación: \(context.codingPath)")
                default:
                    print("Error de codificación desconocido: \(encodingError)")
                }
            }
        }
    }

    private var passwordField: some View {
        ZStack {
            Group {
                if showPassword {
                    TextField("Contraseña", text: $password, prompt: Text("Contraseña").foregroundColor(Color(white: 0.4)).bold())
                } else {
                    SecureField("Contraseña", text: $password, prompt: Text("Contraseña").foregroundColor(Color(white: 0.4)).bold())
                }
            }
            .multilineTextAlignment(.center)
            .padding(10)
            .overlay {
                RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 2)
            }
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.9)))
            .shadow(radius: 2, y: 2)
            .padding(.horizontal)
            .frame(width: 335)
            
            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundColor(Color(white: 0.1)).bold()
            }
            .offset(x: UIScreen.screenWidth / 3 - 10)
        }
    }
    
    private func closeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 35)
                
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
            }
            .padding(8)
            .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .offset(y: UIScreen.screenHeight / 3.1)
    }
    
//    private func verificarActividadesCompletadas() {
//        let fileManager = FileManager.default
//        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileURL = documentsDirectory.appendingPathComponent("actividadesCompletadas.json")
//        
//        if fileManager.fileExists(atPath: fileURL.path) {
//            do {
//                let data = try Data(contentsOf: fileURL)
//                actividadesCompletadas = try JSONDecoder().decode([Bool].self, from: data)
//            } catch {
//                print("Error al decodificar actividadesCompletadas: \(error)")
//            }
//        } else {
//            actividadesCompletadas = Array(repeating: false, count: numActividades+1)
//        }
//    }
    
}

#Preview {
    SignIn()
}
