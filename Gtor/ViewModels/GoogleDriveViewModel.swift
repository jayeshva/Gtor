//
//  FileDetailViewModel.swift
//  Gtor
//
//  Created by JAYESH V A on 14/12/24.
//

import SwiftUI
import UIKit

class GoogleDriveViewModel: ObservableObject {
    let fileOrFolder: GoogleDriveItem
    @AppStorage("accessToken") var accessToken: String?
    @Published var fileURL: URL?
    @Published var items: [GoogleDriveItem] = []
    @Published var filteredItems: [GoogleDriveItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var downloadProgress: Double = 0.0
    @Published var downloadSpeed: String = "0 KB/s"
    @Published var search: String = ""
    
    init(fileOrFolder: GoogleDriveItem) {
           self.fileOrFolder = fileOrFolder
       }

    func downloadFile() {
        isLoading = true
        errorMessage = nil

        let service = GoogleDriveService(accessToken: accessToken!)
        service.fetchFileContent(
            fileOrFolder.id,
            progressHandler: { progress, speed in
                DispatchQueue.main.async {
                    self.downloadProgress = progress
                    self.downloadSpeed = speed
                }
            },
            completion: { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let url):
                        self.fileURL = url
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        )
    }

    func previewFile(_ url: URL) {
        let documentInteractionController = UIDocumentInteractionController(url: url)
        
        // Get the key window for the current scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = keyWindow.rootViewController {
            
            documentInteractionController.delegate = rootViewController as? UIDocumentInteractionControllerDelegate
            documentInteractionController.presentPreview(animated: true)
        } else {
            print("Failed to find a valid window or root view controller.")
        }
    }

    func shareFile(_ url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // Get the key window for the current scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = keyWindow.rootViewController {
            
            rootViewController.present(activityViewController, animated: true, completion: nil)
        } else {
            print("Failed to find a valid window or root view controller.")
        }
    }

    
    func destinationView(for item: GoogleDriveItem) -> some View {
        if item.isFolder {
            return AnyView(FolderDetailView(folder: item))
        } else {
            return AnyView(FileDetailView(file: item))
        }
    }

    func loadItems() {
        isLoading = true
        errorMessage = nil

        let service = GoogleDriveService(accessToken: accessToken!)
        service.fetchItems(inFolder: fileOrFolder.id) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedItems):
                    self.items = fetchedItems
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loadDriveContents() {
        isLoading = true
        errorMessage = nil

        let service = GoogleDriveService(accessToken: accessToken!)
        service.fetchItems(inFolder: "root") { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedItems):
                    self.items = fetchedItems
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
