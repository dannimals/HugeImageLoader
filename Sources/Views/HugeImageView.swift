
import UIKit

public enum HugeImageDownloadError: Error {
    case missingLocalCacheURL
    case failedToMoveItemToLocalCache
    case failedToDownloadItem(error: Error?)
    case failedToSetupLocalCache
}

public protocol HugeImageViewDelegate: class {

    func hugeImageViewDidFinishDownloadingImage(_ hugeImageView: HugeImageView, result: Result<URL, HugeImageDownloadError>)

}

public class HugeImageView: UIView {

    public weak var delegate: HugeImageViewDelegate?

    @IBOutlet weak var scrollView: HugeImageScrollView!

    private var placeholderImage: UIImage!
    private var imageID: String!
    private var imageHasAlpha: Bool!

    lazy var downloadSession: URLSession = {
        let configuration: URLSessionConfiguration = .default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()

    private var highResolutionImageLocalPathURL: URL? {
        let highResComponent = "\(String(describing: imageID))_highResolutionImage"
        return urlPathByAppending(pathComponent: highResComponent)
    }

    private func urlPathByAppending(pathComponent: String) -> URL? {
        return cacheDirectoryURL?.appendingPathComponent(pathComponent)
    }

    private lazy var cacheDirectoryURL: URL? = {
        let cacheDirectoryURL = DataCacheURL.dataCacheDirectoryURL(identifier: "HugeImageLoaderUser")
        return cacheDirectoryURL?.appendingPathComponent("TiledImages")
    }()

    public func loadImages(highResolutionImageDownloadURL: URL, imageID: String, placeholderImage: UIImage, imageHasAlpha: Bool = true) throws {
        guard let cacheDirectoryURL = cacheDirectoryURL else { throw HugeImageDownloadError.failedToSetupLocalCache }

        self.placeholderImage = placeholderImage
        self.imageID = imageID
        self.imageHasAlpha = imageHasAlpha

        let tileCacheManager = TileCacheManager(cacheDirectoryURL: cacheDirectoryURL, imageID: imageID)
        scrollView.load(placeholderImage: placeholderImage, imageID: imageID, tileCacheManager: tileCacheManager, hasAlpha: imageHasAlpha)
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
                let localHighResImageURL = self?.highResolutionImageLocalPathURL,
                let tempFileURL = tempFileURL else {
                    strongSelf.delegate?.hugeImageViewDidFinishDownloadingImage(strongSelf, result: .failure(.missingLocalCacheURL))
                    return
            }
            strongSelf.moveItem(at: tempFileURL, to: localHighResImageURL)
        }
        task.resume()
    }

    private func moveItem(at tempFileURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
            delegate?.hugeImageViewDidFinishDownloadingImage(self, result: .success(destinationURL))
        } catch {
            delegate?.hugeImageViewDidFinishDownloadingImage(self, result: .failure(.failedToMoveItemToLocalCache))
        }
    }

}
