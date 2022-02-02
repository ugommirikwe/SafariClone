//
//  BottomToolbar.swift
//  WebviewApp
//
//  Created by Ugochukwu Mmirikwe on 2022/01/27.
//

import SwiftUI

struct BottomToolbar: View {
    let buttons: [ToolbarIconButton]
    
    var body: some View {
        HStack(spacing: 50) {
            ForEach(buttons) { button in
                ResizableView {
                    ToolbarIconButton(
                        sfSymbolName: button.sfSymbolName,
                        title: button.title,
                        disabled: button.disabled,
                        action: button.action
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResizableView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        HStack {
            Spacer()
            content()
            Spacer()
        }
    }
}

struct ToolbarIconButton: View, Identifiable {
    var id: String { sfSymbolName }
    var sfSymbolName: String
    var title: String?
    var disabled: Binding<Bool>? = Binding(get: { true }, set: { _ in })
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if let title = title,
               !title.isEmpty,
               sfSymbolName.isEmpty {
                Text(title)
            } else {
                Image(systemName: sfSymbolName)
            }
        }
        .font(.system(size: 20))
        .disabled(disabled?.wrappedValue ?? true)
    }
}

struct BottomToolbar_Previews: PreviewProvider {
    static var previews: some View {
        BottomToolbar(buttons: [ToolbarIconButton(sfSymbolName: "square.on.square") {}])
    }
}
