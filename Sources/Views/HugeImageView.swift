
import UIKit

public enum HugeImageDownloadError: Error {
    case missingLocalCacheURL
    case failedToMoveItemToLocalCache
    case failedToDownloadItem(error: Error?)
}

public protocol HugeImageViewDelegate: class {

    func hugeImageViewDidFinishDownloadingImage(_ hugeImageView: HugeImageView, result: Result<URL, HugeImageDownloadError>)

}

public class HugeImageView: UIView {

    public weak var delegate: HugeImageViewDelegate?

    @IBOutlet weak var scrollView: HugeImageScrollView!

    private var placeholderImage: UIImage!
    private var imageIdentifier: String!
    private var imageHasAlpha: Bool!

    lazy var downloadSession: URLSession = {
        let configuration: URLSessionConfiguration = .default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()

    private var highResolutionImageLocalPathURL: URL? {
        let highResComponent = "\(String(describing: imageIdentifier))_highResolutionImage"
        return urlPathByAppending(pathComponent: highResComponent)
    }

    private func urlPathByAppending(pathComponent: String) -> URL? {
        return dataCacheDirectory?.appendingPathComponent(pathComponent)
    }

    private lazy var dataCacheDirectory: URL? = {
        let cacheDirectoryURL = DataCacheURL.dataCacheDirectoryURL(identifier: UUID().uuidString)
        return cacheDirectoryURL?.appendingPathComponent("TiledImages")
    }()

    func loadImages(highResolutionImageDownloadURL: URL, imageIdentifier: String, placeholderImage: UIImage, imageHasAlpha: Bool = true) {
        self.placeholderImage = placeholderImage
        self.imageIdentifier = imageIdentifier
        self.imageHasAlpha = imageHasAlpha
        downloadHighResolutionImage(url: highResolutionImageDownloadURL)
    }

    func downloadHighResolutionImage(url: URL) {
        let task = downloadSession.downloadTask(with: url) { [weak self] (tempFileURL, urlResponse, error) in
            guard let strongSelf = self else { return }

            guard
                let urlResponse = urlResponse as? HTTPURLResponse,
                (200...299).contains(urlResponse.statusCode) else {
                strongSelf.delegate?.hugeImageViewDidFinishDownloadingImage(strongSelf, result: .failure(.failedToDownloadItem(error: error)))
                return
            }

            guard
                let dataCacheDirectory = self?.dataCacheDirectory,
                let localHighResImageURL = self?.highResolutionImageLocalPathURL,
                let tempFileURL = tempFileURL else {
                    strongSelf.delegate?.hugeImageViewDidFinishDownloadingImage(strongSelf, result: .failure(.missingLocalCacheURL))
                    return
            }

            do {
                try FileManager.default.moveItem(at: tempFileURL, to: localHighResImageURL)
                strongSelf.delegate?.hugeImageViewDidFinishDownloadingImage(strongSelf, result: .success(localHighResImageURL))
            } catch {
                DispatchQueue.main.async {
                    let tileCacheManager = TileCacheManager(cacheDirectoryURL: dataCacheDirectory, imageID: strongSelf.imageIdentifier)
                    strongSelf.scrollView.load(placeholderImage: strongSelf.placeholderImage, imageIdentifier: strongSelf.imageIdentifier, tileCacheManager: tileCacheManager, hasAlpha: strongSelf.imageHasAlpha)
                    strongSelf.delegate?.hugeImageViewDidFinishDownloadingImage(strongSelf, result: .failure(.failedToMoveItemToLocalCache))
                }
            }
        }
        task.resume()
    }

}
