//
//  ContentView.swift
//  WebviewApp
//
//  Created by Ugochukwu Mmirikwe on 2022/01/27.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                tabsInGridView
                
                webViews
                
                VStack(spacing: 10) {
                    Divider()
                    
                    addressBar
                    bottomToolBarButtons
                }
                .background(.thinMaterial)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarCancel()
            }
        }
    }
    
    @StateObject var tabManager = TabsManager()
    
    @State private var isInGridView: Bool = false
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State var scrollViewOffset: CGFloat = .zero
    
    private static let screenWidth = UIScreen.main.bounds.width
    private static let buttonWidth = UIScreen.main.bounds.width * 0.5
    
    @FocusState private var focusedTabURLField: String?
    
    @State private var addressBarDragAmount: CGSize = .zero
    private let addressBarHorizontalScrollingTracker = PassthroughSubject<CGFloat, Never>()
    @State var cancellables: [AnyCancellable] = []
    
    @ViewBuilder private var tabsInGridView: some View {
        if isInGridView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 40) {
                    
                    ForEach($tabManager.tabs) { $tab in
                        ZStack(alignment: .topTrailing) {
                            WebView(webView: tab.webView)
                                .frame(height: 200)
                            
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .padding(8)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(tabManager.tabs.firstIndex(where: { $0.id == tab.id }) == tabManager.tabActive ? 3 : 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.accentColor, lineWidth: tabManager.tabs.firstIndex(where: { $0.id == tab.id }) == tabManager.tabActive ? 2 : 0)
                        )
                        .shadow(color: .gray, radius: 50, x: 0, y: 20)
                        .edgesIgnoringSafeArea(.top)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                tabManager.tabActive = tabManager.tabs.firstIndex(where: { $0.id == tab.id }) ?? 0
                                isInGridView = false
                            }
                        }
                    }
                    
                }
                .padding()
            }
            .background(.thinMaterial)
            .transition(.scale)
        }
    }
    
    @ViewBuilder private var webViews: some View {
        if !isInGridView {
            TabView(selection: $tabManager.tabActive) {
                ForEach($tabManager.tabs) { $tab in
                    WebView(webView: tab.webView)
                        .gesture(DragGesture()) // <= prevents the default TabView page swipe
                        //.offset(x: tabManager.tabs.firstIndex(where: { $0.id == tab.id }) == tabManager.tabActive ? 0 : -ContentView.screenWidth)
                        .offset(x: scrollViewOffset)
                }
            }
            .offset(y: addressBarDragAmount.height)
            .tabViewStyle(.page)
        }
    }
    
    @ViewBuilder private var addressBar: some View {
        if !isInGridView {
            ScrollViewReader { container in
                ScrollView(.horizontal, showsIndicators: false) {
                    offsetReader
                    
                    LazyHStack(spacing: 8) {
                        ForEach($tabManager.tabs) { $tab in
                            
                            SearchURLInputField(
                                input: $tab.urlString,
                                inputFieldID: tab.id,
                                isInputActive: _focusedTabURLField
                            ) { _ in
                                tab.loadUrl()
                            }
                            .padding(.leading, tabManager.tabs.firstIndex(where: { $0.id == tab.id }) == 0 ? 16 : 0)
                            .frame(width: ContentView.screenWidth * 0.9)
                            .id(tab.id)
                            
                        }
                        
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                            .frame(width: ContentView.buttonWidth)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .padding(.vertical)
                    .padding(.top, -8)
                    
                }
                .frame(height: 40)
                .simultaneousGesture(addressBarSwipeUpGesture)
                .coordinateSpace(name: "frameLayer")
                .onPreferenceChange(OffsetPreferenceKey.self) { value in
                    DispatchQueue.main.async {
                        scrollViewOffset = value
                        addressBarHorizontalScrollingTracker.send(value)
                    }
                }
                .onAppear {
                    setUpAddressBarHorizontalScrollingHandler(container)
                }
            }
        }
    }
    
    private var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("frameLayer")).minX
                )
        }
        .frame(height: 0) // <= just so the reader doesn't affect the content height
    }
    
    private var addressBarSwipeUpGesture: some Gesture {
        DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onChanged { newValue in
                withAnimation(.linear) {
                    addressBarDragAmount = newValue.translation
                }
            }
            .onEnded { value in
                if value.translation.height < 0 && value.translation.width < 100 && value.translation.width > -100 {
                    onBottomToolbarGridButtonTap()
                    addressBarDragAmount = .zero
                }
            }
    }
    
    private func setUpAddressBarHorizontalScrollingHandler(_ container: ScrollViewProxy) {
        addressBarHorizontalScrollingTracker
            .dropFirst()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .buffer(size: 10, prefetch: .byRequest, whenFull: .dropOldest)
            .sink { newValue in
                // Check if the value is negative (i.e. scrolling forward) or positive (i.e. scrolling backward)
                if newValue < 0 {
                    
                    // If we scroll far enough, create a new tab ONLY if we're at the last tab and this tab has a loaded
                    // webpage. Prevents from loading several tabs with empty pages.
                    if abs(newValue) >= ContentView.screenWidth * 0.5 {
                        if tabManager.canCreateNewTab {
                            tabManager.createNewTab()
                            container.scrollTo(tabManager.tabs[tabManager.tabActive].id)
                        }
                    }
                } else {
                    // if scrolling backward, show the previous tab, if the current one is not the firstmost tab
                    if tabManager.tabActive - 1 >= 0 {
                        tabManager.tabActive -= 1
                        container.scrollTo(tabManager.tabs[tabManager.tabActive].id)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @ViewBuilder private var bottomToolBarButtons: some View {
        if isInGridView {
            BottomToolbar(buttons: [
                ToolbarIconButton(
                    sfSymbolName: "plus",
                    disabled: Binding(get: {!tabManager.canCreateNewTab}, set: { _  in })
                ) {
                    tabManager.createNewTab()
                },
                ToolbarIconButton(
                    sfSymbolName: "",
                    title: "Done",
                    disabled: Binding(get: { false }, set: { _  in })
                ) {
                    onBottomToolbarGridButtonTap()
                }
            ]).padding(8)
        } else {
            BottomToolbar(buttons: [
                ToolbarIconButton(
                    sfSymbolName: "chevron.backward",
                    disabled: !$tabManager.tabs[tabManager.tabActive].canGoBack
                ) {
                    tabManager.tabs[tabManager.tabActive].goBack()
                },
                ToolbarIconButton(
                    sfSymbolName: "chevron.forward",
                    disabled: !$tabManager.tabs[tabManager.tabActive].canGoForward
                ) {
                    tabManager.tabs[tabManager.tabActive].goBack()
                },
                ToolbarIconButton(sfSymbolName: "square.and.arrow.up") {},
                ToolbarIconButton(sfSymbolName: "book") {},
                ToolbarIconButton(
                    sfSymbolName: "square.on.square",
                    disabled: Binding(get: { false }, set: { _ in }),
                    action: onBottomToolbarGridButtonTap
                )
            ]).padding(8)
        }
    }
    
    private func onBottomToolbarGridButtonTap() {
        withAnimation(.spring().speed(0.7)) {
            isInGridView.toggle()
        }
    }
    
    private func toolbarCancel() -> ToolbarItemGroup<Button<Text>?> {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if focusedTabURLField != nil {
                Button("Cancel") {
                    withAnimation(.easeInOut) {
                        focusedTabURLField = nil
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ContentView()
        }
    }
}

struct OffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}


