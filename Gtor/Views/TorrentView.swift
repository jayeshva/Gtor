import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct TorrentView: View {
    
    @EnvironmentObject var viewModel: TorrentViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Torrent Downloader")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)

            if let name = viewModel.user?.profile?.name {
                Text("Welcome, \(name)!")
                    .font(.headline)
            }

            TextField("Enter Magnet Link", text: $viewModel.magnetLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: viewModel.submitMagnetLink) {
                Text("Submit Magnet Link")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            DownloadsView(downloads: $viewModel.downloads)

            Button(action: viewModel.signOut) {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            if let token = viewModel.accessToken {
                viewModel.webSocketManager.connect(token: token)
                viewModel.webSocketManager.onMessageReceived = { message in
                    viewModel.handleWebSocketMessage(message)
                }
            }
        }
        .onDisappear {
            viewModel.webSocketManager.disconnect()
        }
    }

}
