
import Foundation

class GoogleDriveService: NSObject, URLSessionDownloadDelegate {
    private let accessToken: String

    private var progressHandler: ((Double, String) -> Void)?
    private var completionHandler: ((Result<URL, Error>) -> Void)?
    private var lastUpdateTime = Date()

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    func fetchFolders(completion: @escaping (Result<[GoogleDriveFolder], Error>) -> Void) {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files?q=mimeType='application/vnd.google-apps.folder' and 'root' in parents&spaces=drive&fields=files(id,name)&pageSize=50")!
        makeRequest(url: url, completion: completion)
    }

    func fetchFiles(inFolder folderId: String, completion: @escaping (Result<[GoogleDriveFile], Error>) -> Void) {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files?q='\(folderId)' in parents&fields=files(id,name)&pageSize=50")!
        makeRequest(url: url, completion: completion)
    }

    func fetchFileContent(
        _ fileId: String,
        progressHandler: @escaping (Double, String) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files/\(fileId)?alt=media")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        self.progressHandler = progressHandler
        self.completionHandler = completion

        // Configure session with delegate
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: request)
        task.resume()
    }

    func fetchItems(inFolder folderId: String, completion: @escaping (Result<[GoogleDriveItem], Error>) -> Void) {
        let url = URL(string: "https://www.googleapis.com/drive/v3/files?q='\(folderId)' in parents&fields=files(id,name,mimeType)&pageSize=50")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let driveResponse = try JSONDecoder().decode(GoogleDriveResponse<GoogleDriveItem>.self, from: data)
                completion(.success(driveResponse.files))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func makeRequest<T: Codable>(url: URL, completion: @escaping (Result<[T], Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let driveResponse = try JSONDecoder().decode(GoogleDriveResponse<T>.self, from: data)
                completion(.success(driveResponse.files))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - URLSessionDownloadDelegate Methods

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }

        // Calculate progress
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        // Calculate download speed
        let now = Date()
        let timeElapsed = now.timeIntervalSince(lastUpdateTime)
        lastUpdateTime = now

        let speed = Double(bytesWritten) / timeElapsed / 1024 // Speed in KB/s
        let formattedSpeed = String(format: "%.2f KB/s", speed)

        // Notify progress handler on the main thread
        DispatchQueue.main.async {
            self.progressHandler?(progress, formattedSpeed)
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let destinationURL = tempDirectory.appendingPathComponent(
            downloadTask.response?.suggestedFilename ?? UUID().uuidString
        )

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: location, to: destinationURL)

            // Notify completion handler on the main thread
            DispatchQueue.main.async {
                self.completionHandler?(.success(destinationURL))
            }
        } catch {
            DispatchQueue.main.async {
                self.completionHandler?(.failure(error))
            }
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error {
            DispatchQueue.main.async {
                self.completionHandler?(.failure(error))
            }
        }
    }
}
