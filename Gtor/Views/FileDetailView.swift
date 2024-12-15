//
//  FileDetailView.swift
//  Gtor
//
//  Created by JAYESH V A on 30/11/24.
//



import SwiftUI
import UIKit

struct FileDetailView: View {
    @StateObject private var viewModel: GoogleDriveViewModel
    
    init(file: GoogleDriveItem) {
            _viewModel = StateObject(wrappedValue: GoogleDriveViewModel(fileOrFolder: file))
    }


    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView(value: viewModel.downloadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                   
                    Text("Download Progress: \(viewModel.downloadProgress * 100, specifier: "%.2f")%")
                    Text("Download Speed: \(viewModel.downloadSpeed)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else if let fileURL = viewModel.fileURL {
                Button("Preview File") {
                    viewModel.previewFile(fileURL)
                }
                .padding()

                Button("Share File") {
                    viewModel.shareFile(fileURL)
                }
                .padding()
            } else {
                Text("No file available.")
            }
        }
        .navigationTitle(viewModel.fileOrFolder.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.downloadFile()
        }
    }

}
