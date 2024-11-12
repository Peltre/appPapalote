//
//  WebView.swift
//  proyectoReto
//
//  Created by Pedr1p on 05/11/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        // Crear la instancia de WKWebView
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Cargar la URL en la WebView
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
