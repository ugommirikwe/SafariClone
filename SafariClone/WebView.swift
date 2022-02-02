//
//  WebsiteViewer.swift
//  WebviewApp
//
//  Created by Ugochukwu Mmirikwe on 2022/01/27.
//

import SwiftUI
import WebKit
import Combine

struct WebView: UIViewRepresentable {
    var webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<WebView>) {
    }
}
