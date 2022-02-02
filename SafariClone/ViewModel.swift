//
//  ViewModel.swift
//  SafariClone
//
//  Created by Ugochukwu Mmirikwe on 2022/02/02.
//

import Combine
import SwiftUI
import WebKit

class TabsManager: ObservableObject {
    static let defaultURLString = "https://google.com"
    @Published var tabs: [Tab] = [Tab(urlString: TabsManager.defaultURLString)]
    @Published var tabActive: Int = 0
    
    var canCreateNewTab: Bool {
        let lastTab = tabs[tabs.count - 1]
        if lastTab.urlString.parseAsURL() != nil &&
            self.tabActive + 1 >= tabs.count {
            return true
        }
        
        return false
    }
    
    func createNewTab() {
        if canCreateNewTab {
            tabs.append(Tab(urlString: ""))
            
            // then switch to the new tab
            tabActive = tabs.count - 1
        }
    }
}

class Tab: ObservableObject, Identifiable {
    static let defaultURLString = "https://google.com"
    let id: String = UUID().uuidString
    var webView: WKWebView
    
    @Published var urlString: String = ""
    
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    init(urlString: String = "") {
        self.urlString = urlString
        webView = WKWebView(frame: .zero)
        setupBindings()
        loadUrl()
    }
    
    func loadUrl() {
        guard let url = urlString.parseAsURL() else {
            return
        }
        
        urlString = url.absoluteString
        
        webView.load(URLRequest(url: url))
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
        
        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
    }
}
