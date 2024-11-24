//
//  Utils.swift
//  PruebaMapas
//
//  Created by Alumno on 14/10/24.
//

import SwiftUI

let pathDictionary: [String: (Color,String)] = [
    "Path 21": (Color(red: 1.0, green: 0.475, blue: 0.137),"Expreso"),   // Naranja - Expreso
    "Path 22": (Color(red: 1.0, green: 0.192, blue: 0.106),"Soy"),   // Rojo - Soy
    "Path 23": (Color(red: 0.333, green: 0.804, blue: 0.816),"Pequeños"), // Celeste - Pequeños
    "Path 31": (Color(red: 0.475, green: 0.275, blue: 0.643),"Comprendo"), // Morado - Comprendo
    "Path 25" : (Color(red: 0.45, green: 0.45, blue: 0.45), ""), // Color Escalera
    "Path 30" : (Color(red: 0.45, green: 0.45, blue: 0.45), ""), // Color Escalera
    "Path 68" : (Color(red: 0.6, green: 0.82, blue: 0.57), ""), // Dinosaurio
    "Path 26" : (Color(red: 0.56, green: 0.79, blue: 0.28), "Pertenezco"), // Verde - Pertenezco
    "Path 27" : (Color(red: 0.16, green: 0.43, blue: 0.73), "Comunico"), // Azul - Comunico
    "Path 28" : (Color(red: 0.333, green: 0.804, blue: 0.816), "Pequeños") // Celeste - Pequeños
]

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

let colores : [Int : Color] = [
    1 : Color(red: 1.0, green: 0.475, blue: 0.137), // Expreso
    2 : Color(red: 0.16, green: 0.43, blue: 0.73), // Comunico
    3 : Color(red: 0.56, green: 0.79, blue: 0.28), // Pertenezco
    4 : Color(red: 0.475, green: 0.275, blue: 0.643), // Comprendo
    5 : Color(red: 1.0, green: 0.192, blue: 0.106), // Soy
    6 : Color(red: 0.333, green: 0.804, blue: 0.816), // Pequenos
    0 : Color.black
]

let mapaDetallado : [Int : String] = [
    1 : "NaranjaDetallado",
    2 : "AzulDetallado",
    3 : "VerdeDetallado",
    4 : "MoradoDetallado",
    5 : "RojoDetallado",
    6 : "CelesteDetallado",
    0 : "p"
]

let apiURLbase : String = "https://r1aguilar.pythonanywhere.com/"

extension String {
    func removeAccents() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
}

let iconosZonas : [Int : String] = [
    1 : "IconoExpreso",
    2 : "IconoComunico",
    3 : "IconoPertenezco",
    4 : "IconoComprendo",
    5 : "IconoSoy",
    6 : "IconoPeque"
]

// Add this class to your App delegate or create it if it doesn't exist
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Imprimir el contenido del directorio de documentos
//        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            do {
//                let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
//                print("Archivos en el directorio de documentos:")
//                files.forEach { print($0) }
//            } catch {
//                print("Error al listar archivos: \(error)")
//            }
//        }
        return AppDelegate.orientationLock
    }
}

// Add this to support orientation locking
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content.onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// Extension to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
