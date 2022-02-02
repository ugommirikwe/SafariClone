//
//  SearchURLInputField.swift
//  WebviewApp
//
//  Created by Ugochukwu Mmirikwe on 2022/01/27.
//

import SwiftUI

struct SearchURLInputField: View {
    @Binding var input: String
    let inputFieldID: String
    @FocusState var isInputActive: String?
    
    let onGoTapped: (String) -> Void
    
    private let placeholder = NSLocalizedString("Search or enter website", comment: "")
    
    var body: some View {
        HStack {
            Button(action: {
                isInputActive = inputFieldID
            }) {
                Image(systemName: "magnifyingglass")
            }
            
            TextField(placeholder, text: $input)
                .keyboardType(.webSearch)
                .submitLabel(.go)
                .onSubmit {
                    onGoTapped(input)
                }
                .focused($isInputActive, equals: inputFieldID)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        
                        HStack {
                            TextField(placeholder, text: $input)
                                .padding(.horizontal)
                            
                            Button(action: {}) {
                                Image(systemName: "mic.fill")
                            }
                            
                            if !input.isEmpty {
                                Button(action: {
                                    input = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                }
                                .transition(.slide)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut, value: input)
                        .foregroundColor(.secondary)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        
                    }
                }
            
            Button(action: {}) {
                Image(systemName: "mic.fill")
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .foregroundColor(.secondary)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

struct SearchURLInputField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            SearchURLInputField(input: .constant(""), inputFieldID: UUID().uuidString) {_ in }
        }
    }
}
