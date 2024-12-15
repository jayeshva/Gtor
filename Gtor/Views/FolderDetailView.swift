//
//  FolderDetailView.swift
//  Gtor
//
//  Created by JAYESH V A on 30/11/24.
//

import SwiftUI

struct FolderDetailView: View {
    @StateObject private var viewModel: GoogleDriveViewModel
    
    init(folder: GoogleDriveItem) {
            _viewModel = StateObject(wrappedValue: GoogleDriveViewModel(fileOrFolder: folder))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading Items...")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(viewModel.items, id: \.id) { item in
                    NavigationLink(
                        destination: viewModel.destinationView(for: item)
                    ) {
                        HStack {
                            Image(systemName: item.isFolder ? "folder" : "doc").backgroundStyle(.green)
                            Text(item.name)
                            
                        }.contextMenu(Menu.menuItems)
                    }
                }
            }
        }
        .navigationTitle(viewModel.fileOrFolder.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadItems()
        }
    }

}
