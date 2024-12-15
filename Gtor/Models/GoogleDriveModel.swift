//
//  GoogleDriveFolder.swift
//  play
//
//  Created by JAYESH V A on 30/11/24.
//


import Foundation

struct GoogleDriveFolder: Codable {
    let id: String
    let name: String
}

struct GoogleDriveFile: Codable {
    let id: String
    let name: String
}


struct GoogleDriveItem: Codable {
    let id: String
    let name: String
    let mimeType: String

    var isFolder: Bool {
        mimeType == "application/vnd.google-apps.folder"
    }
}

struct GoogleDriveResponse<T: Codable>: Codable {
    let files: [T]
}

struct DownloadProgress {
    let torrentId: String
    let name: String
    let progress: Double
    let downloadSpeed: String
    let peers: Int
}


