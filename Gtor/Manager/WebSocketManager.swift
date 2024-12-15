//
//  WebSocketManager.swift
//  Gtor
//
//  Created by JAYESH V A on 14/12/24.
//


import Foundation

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var isConnected: Bool = false

    var onMessageReceived: ((String) -> Void)?

    func connect(token: String) {
        guard webSocketTask == nil else {
            print("WebSocket is already connected.")
            return
        }

        let backendURL = "ws://localhost:3000?access_token=\(token)"
//        let backendURL = "ws://tv68mn4p-3000.inc1.devtunnels.ms?access_token=\(token)"
        guard let url = URL(string: backendURL) else {
            print("Invalid WebSocket URL.")
            return
        }

        session = URLSession(configuration: .default)
        webSocketTask = session?.webSocketTask(with: url)
        webSocketTask?.resume()

        listenForMessages()

        // Verify connection status
        checkConnectionStatus()
    }

    private func checkConnectionStatus() {
        guard let task = webSocketTask else { return }
        task.sendPing { error in
            if let error = error {
                print("WebSocket ping failed: \(error.localizedDescription)")
                self.isConnected = false
                self.reconnect()
            } else {
                print("WebSocket is connected.")
                self.isConnected = true
            }
        }
    }

    func send(message: URLSessionWebSocketTask.Message) {
        guard isConnected else {
            print("WebSocket is not connected. Reconnecting...")
            reconnect()
            return
        }

        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error.localizedDescription)")
                self.isConnected = false
                self.reconnect()
            }
        }
    }

    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    DispatchQueue.main.async {
                        self.onMessageReceived?(text)
                    }
                }
                self.listenForMessages() // Continue listening
            case .failure(let error):
                print("WebSocket receive error: \(error.localizedDescription)")
                self.isConnected = false
                self.reconnect()
            }
        }
    }

    private func reconnect() {
        guard let task = webSocketTask else { return }
        task.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        // Retry after a delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("Attempting to reconnect WebSocket...")
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                self.connect(token: token)
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        session = nil
        isConnected = false
    }
}
