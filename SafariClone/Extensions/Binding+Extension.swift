//
//  Binding+Extension.swift
//  SafariClone
//
//  Created by Ugochukwu Mmirikwe on 2022/02/03.
//

import SwiftUI

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}
