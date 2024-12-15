import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    
    @EnvironmentObject var viewModel: TorrentViewModel

    var body: some View {
        VStack() {
            if viewModel.isAuthenticated {
                AuthenticatedTabView()
            } else {
                GoogleSignInButton(action: viewModel.handleSignInButton)
                    .frame(height: 50)
                    .padding(.horizontal)
                Text(viewModel.statusMessage)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear(perform: viewModel.restoreSignInState)
    }
  
}

