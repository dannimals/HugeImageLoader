
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

    public func configure(highResolutionImageRemoteURL: URL, imageID: String, placeholderImage: UIImage, fullImageSize: CGSize, imageHasAlpha: Bool = true) {
        let tileCacheManager = TileCacheManager(highResolutionImageRemoteURL: highResolutionImageRemoteURL, imageID: imageID)
        tileCacheManager.delegate = self
        scrollView.configure(placeholderImage: placeholderImage, imageID: imageID, tileCacheManager: tileCacheManager, hasAlpha: imageHasAlpha, fullImageSize: fullImageSize)
    }

}

extension HugeImageView: TileCacheManagerDelegate {

    func tileCacheManagerDidFinishDownloadingHighResolutionImage(_ tileCacheManager: TileCacheManager, withResult result: Result<URL, HugeImageDownloadError>) {
        DispatchQueue.main.async {
            self.delegate?.hugeImageViewDidFinishDownloadingImage(self, result: result)
        }
    }

}
