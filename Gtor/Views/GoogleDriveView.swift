//
//  GoogleDriveView.swift
//  play
//
//  Created by JAYESH V A on 30/11/24.
//

import SwiftUI


struct GoogleDriveView: View {
    
    @StateObject private var viewModel: GoogleDriveViewModel
    
    init(file: GoogleDriveItem) {
            _viewModel = StateObject(wrappedValue: GoogleDriveViewModel(fileOrFolder: file))
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Drive...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.filteredItems, id: \.id) { item in
                        NavigationLink(
                            destination: viewModel.destinationView(for: item)
                        ) {
                            HStack {
                                Image(systemName: item.isFolder ? "folder" : "doc")
                                Text(item.name)
                            }
                        }.contextMenu(Menu.menuItems)
                    }.searchable(text: $viewModel.search )
                        .onChange(of: viewModel.search){
                            if viewModel.search.isEmpty {
                                viewModel.filteredItems = viewModel.items
                            }
                            else {
                                viewModel.filteredItems = viewModel.items.filter { $0.name.lowercased().contains(viewModel.search.lowercased()) }
                            }
                        }
                }
            }
            .onAppear {
                print("GoogleDriveView appeared with accessToken: \(viewModel.accessToken!)")
                viewModel.loadDriveContents()
                viewModel.filteredItems = viewModel.items
            }
        }
    }

    
}


// MARK: - Preview

struct GoogleDriveView_Previews: PreviewProvider {
    static var previews: some View {
        
        GoogleDriveView(file: GoogleDriveItem(id: "root", name: "", mimeType: ""))
    }
}
