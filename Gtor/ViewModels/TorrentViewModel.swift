//
//  TorrentViewModel.swift
//  Gtor
//
//  Created by JAYESH V A on 14/12/24.
//


import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

class TorrentViewModel: ObservableObject {
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @Published var magnetLink: String = ""
    @Published var statusMessage: String = "Sign in to Google to begin."
    @AppStorage("accessToken") var accessToken: String?
    @Published var user: GIDGoogleUser?
    @Published var downloads: [String: DownloadProgress] = [:]
    let webSocketManager: WebSocketManager
    
    init(webSocketManager: WebSocketManager) {
            self.webSocketManager = webSocketManager
     }
    
    func submitMagnetLink() {
        guard let token = accessToken, !magnetLink.isEmpty else {
            statusMessage = "Please provide a valid magnet link and sign in."
            return
        }

        let message = [
            "magnet_link": magnetLink,
            "access_token": token
        ]
        if let data = try? JSONSerialization.data(withJSONObject: message) {
            webSocketManager.send(message: .data(data))
        }
    }

    func handleWebSocketMessage(_ message: String) {
        if let data = message.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let torrentId = json["torrentId"] as? String {
            DispatchQueue.main.async {
                print(json)
                let name = json["name"] as? String ?? "Unknown"
                let progress = Double(json["progress"] as? String ?? "0.0") ?? 0.0
                let downloadSpeed = json["downloadSpeed"] as? String ?? "0 KB/s"
                let peers = json["peers"] as? Int ?? 0

                self.downloads[torrentId] = DownloadProgress(
                    torrentId: torrentId,
                    name: name,
                    progress: progress,
                    downloadSpeed: downloadSpeed,
                    peers: peers
                )
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        user = nil
        isAuthenticated = false
        statusMessage = "Signed out successfully."
        UserDefaults.standard.removeObject(forKey: "accessToken")
        webSocketManager.disconnect()
    }
    
    func handleSignInButton() {
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else {
            statusMessage = "Unable to find root view controller."
            return
        }
        let scopes = ["https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/drive.file"]
        GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController,
                hint: nil,
                additionalScopes: scopes
            ) { signInResult, error in
            if let error = error {
                self.statusMessage = "Sign-in failed: \(error.localizedDescription)"
                return
            }

            guard let signInResult = signInResult else {
                self.statusMessage = "Sign-in result is empty."
                return
            }

            self.user = signInResult.user
            self.accessToken = signInResult.user.accessToken.tokenString
            self.isAuthenticated = true
            self.statusMessage = "Signed in as \(signInResult.user.profile?.name ?? "Unknown")."

                self.saveSignInState(user: signInResult.user)
        }
    }

    func restoreSignInState() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.statusMessage = "Failed to restore sign-in: \(error.localizedDescription)"
                return
            }
            guard let user = user else {
                self.statusMessage = "No previous sign-in found."
                return
            }
            // Access token is refreshed if necessary
            self.user = user
            self.accessToken = user.accessToken.tokenString
            self.isAuthenticated = true
            self.statusMessage = "Welcome back, \(user.profile?.name ?? "Unknown")."
            print(self.accessToken!)
        }
    }


    func saveSignInState(user: GIDGoogleUser) {
        UserDefaults.standard.set(user.accessToken.tokenString, forKey: "accessToken")
    }

  
}

