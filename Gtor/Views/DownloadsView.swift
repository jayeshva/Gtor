//
//  DownloadsView.swift
//  Gtor
//
//  Created by JAYESH V A on 14/12/24.
//

import SwiftUI

struct DownloadsView : View {
    @Binding var downloads: [String: DownloadProgress];
    
    var body: some View {
        List(downloads.keys.sorted(), id: \.self) { torrentId in
            if let progress = downloads[torrentId] {
                VStack(alignment: .leading) {
                    Text("Torrent: \(progress.name)")
                        .font(.headline)
                    ProgressView(value: progress.progress / 100.0)
                        .progressViewStyle(LinearProgressViewStyle())
                    Text("Progress: \(progress.progress, specifier: "%.2f")%")
                    Text("Speed: \(progress.downloadSpeed) KB/s | Peers: \(progress.peers)")
                        .font(.caption)
                }
                .padding(.vertical)
            }
        }
    }
    
}
