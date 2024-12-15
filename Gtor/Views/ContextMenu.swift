//
//  ContextMenu.swift
//  Gtor
//
//  Created by JAYESH V A on 14/12/24.
//

import SwiftUI

struct Menu {
    static let menuItems = ContextMenu {
        Button() {
            
        } label: {
            Label("Info", systemImage: "info.circle")
        }
        Button(role: .destructive) {
            
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
