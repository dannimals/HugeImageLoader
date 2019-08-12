
import UIKit

protocol DownloadManagerDelegate: class {

    func downloadManagerDidFinishDownloading(_ downloadManager: DownloadManaging, withResult result: Result<URL, HugeImageDownloadError>)

}

protocol DownloadManaging {

    var delegate: DownloadManagerDelegate? { get set }

    func downloadImageFromURL(_ url: URL)

}

class DownloadManager: DownloadManaging {

    private lazy var downloadSession: URLSession = {
        let configuration: URLSessionConfiguration = .default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()

    weak var delegate: DownloadManagerDelegate?

    func downloadImageFromURL(_ url: URL) {
        let task = downloadSession.downloadTask(with: url) { [weak self] (tempFileURL, urlResponse, error) in
            guard let strongSelf = self else { return }

            guard
                let urlResponse = urlResponse as? HTTPURLResponse,
                (200...299).contains(urlResponse.statusCode) else {
                    strongSelf.delegate?.downloadManagerDidFinishDownloading(strongSelf, withResult: .failure(.failedToDownloadItem(error: error)))
                    return
            }

            guard let tempFileURL = tempFileURL else {
                strongSelf.delegate?.downloadManagerDidFinishDownloading(strongSelf, withResult: .failure(.missingLocalCacheURL))
                return
            }

            strongSelf.delegate?.downloadManagerDidFinishDownloading(strongSelf, withResult: .success(tempFileURL))
        }
        task.resume()
    }

}
