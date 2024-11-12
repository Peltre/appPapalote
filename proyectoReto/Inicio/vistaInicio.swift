import SwiftUI

struct InicioView: View {
    
    // Colores para utilizar (oficiales del papalote)
    var colorVerde = Color(red: 190 / 255.0, green: 214 / 255.0, blue: 0 / 255.0)
    var colorVerdeOscuro = Color(red: 0 / 255.0, green: 150 / 255.0, blue: 167 / 255.0)
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [colorVerde, colorVerdeOscuro]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Inicio")
                    .font(.system(size: 40))
                    .fontWeight(.black)
                    .offset(x: -UIScreen.screenWidth/3.2, y: -UIScreen.screenHeight/2.54)
                // Background circles
                ZStack {
                    Circle()
                        .fill(colorVerde.opacity(0.3))
                        .frame(width: 300, height: 300)
                        .offset(x: -100, y: -300)
                    
                    Circle()
                        .fill(colorVerdeOscuro.opacity(0.3))
                        .frame(width: 250, height: 250)
                        .offset(x: 150, y: -150)
                    
                    Circle()
                        .fill(colorVerde.opacity(0.2))
                        .frame(width: 350, height: 350)
                        .offset(x: -50, y: 100)
                    
                    Circle()
                        .fill(colorVerdeOscuro.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .offset(x: 150, y: 350)
                    Circle()
                        .fill(colorVerdeOscuro.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .offset(x: -150, y: 280)
                }
                
                VStack {
                    // Perfil button en la parte superior
                    HStack {
                        Spacer()
                        NavigationLink(destination: Perfil()) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: ContentViewMapas()) {
                        Label("Entrar", systemImage: "arrow.right.circle.fill")
                            .padding()
                            .background(colorVerde)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.largeTitle)
                            .bold()
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 20) {
                            NavigationLink(destination: vistaEventos()) {
                                Text("Eventos")
                                    .frame(width: 150, height: 150)
                                    .background(Capsule().fill(colorVerde))
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                                    .shadow(color: .gray, radius: 3, x: 0, y: 3)
                            }
                            NavigationLink(destination: vistaNoticias()) {
                                Text("Noticias")
                                    .frame(width: 150, height: 150)
                                    .background(Capsule().fill(colorVerde))
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                                    .shadow(color: .gray, radius: 3, x: 0, y: 3)
                            }
                        }
                        VStack(spacing: 20) {
                            NavigationLink(destination: ContentView()) {
                                Text("Medallas")
                                    .frame(width: 150, height: 150)
                                    .background(Capsule().fill(colorVerde))
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                                    .shadow(color: .gray, radius: 3, x: 0, y: 3)
                            }
                            NavigationLink(destination: InicioOverhaul(idZona: 2)) {
                                Text("Tutorial")
                                    .frame(width: 150, height: 150)
                                    .background(Capsule().fill(colorVerde))
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                                    .shadow(color: .gray, radius: 3, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.bottom, 170)
                }
                .navigationBarBackButtonHidden(true)
                
            }
        }
    }
}

#Preview {
    InicioView()
}
