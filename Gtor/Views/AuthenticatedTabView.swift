//
//  AuthenticatedTabView.swift
//  play
//
//  Created by JAYESH V A on 30/11/24.
//


import SwiftUI

struct AuthenticatedTabView: View {
    @AppStorage("accessToken") private var accessToken: String?

    var body: some View {
        TabView {
            TorrentView()
                .tabItem {
                    Label("Torrent", systemImage: "arrow.down.circle")
                }
            NavigationView {
                GoogleDriveView(file: GoogleDriveItem(id: "root", name: "", mimeType: ""))
                    .navigationTitle("Google Drive")
            } .tabItem {
                        Label("Google Drive", systemImage: "cloud")
                    }
            TorrentView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            
        }
    }
}
