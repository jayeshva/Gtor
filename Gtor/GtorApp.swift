//
//  GtorApp.swift
//  Gtor
//
//  Created by JAYESH V A on 13/12/24.
//

import SwiftUI
import GoogleSignIn

@main
struct GtorApp: App {
    @StateObject private var torrentViewModel = TorrentViewModel(webSocketManager:WebSocketManager())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
             .environmentObject(torrentViewModel)
             .onOpenURL { url in
              GIDSignIn.sharedInstance.handle(url)
           }
        }
    }
}
