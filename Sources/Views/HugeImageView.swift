
import UIKit

public enum HugeImageDownloadError: Error {

    case missingLocalCacheURL
    case failedToMoveItemToLocalCache
    case failedToDownloadItem(error: Error?)
    case failedToSetupLocalCache

}

public struct ImageCacheIdentifier {
    let id: String
}

public protocol HugeImageViewDelegate: class {

    func hugeImageViewDidFinishDownloadingImage(_ hugeImageView: HugeImageView, result: Result<URL, HugeImageDownloadError>)

}

public struct HugeImageOptions {
    let imageID: String?
    let imageHasAlpha: Bool
    let placeholderImage: UIImage
    let fullImageSize: CGSize
}

public class HugeImageView: UIView, StoryboardNestable, ViewStylePreparing {

    public weak var delegate: HugeImageViewDelegate?

    public var drawingView: UIView? {
        return hugeImageScrollView.drawingContainerView
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var hugeImageScrollView: HugeImageScrollView!


    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadViewFromNib()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func setupViews() {
        hugeImageScrollView.delegate = self
    }

    func setupColors() {
        contentView.backgroundColor = .clear
    }

}

extension HugeImageView {

    @discardableResult
    public func load(highResolutionImageRemoteURL: URL, placeholderImage: UIImage, fullImageSize: CGSize) -> ImageCacheIdentifier {
        layoutIfNeeded()
        let coverImageSize = constrainSizeToBounds(desiredSize: fullImageSize)
        let tileCacheManager = TileCacheManager(highResolutionImageRemoteURL: highResolutionImageRemoteURL, hugeImageViewSize: bounds.size, coverImageSize: coverImageSize)
        tileCacheManager.delegate = self
        let imageCacheIdentifier = tileCacheManager.imageCacheIdentifier
        hugeImageScrollView.configure(placeholderImage: placeholderImage, tileCacheManager: tileCacheManager, hasAlpha: true,
                                      fullImageSize: fullImageSize, coverImageSize: coverImageSize, imageCacheIdentifier: imageCacheIdentifier)
        return imageCacheIdentifier
    }

    @discardableResult
    public func load(highResolutionImageRemoteURL: URL, withOptions options: HugeImageOptions) -> ImageCacheIdentifier {
        layoutIfNeeded()
        let coverImageSize = constrainSizeToBounds(desiredSize: options.fullImageSize)
        let tileCacheManager = TileCacheManager(highResolutionImageRemoteURL: highResolutionImageRemoteURL, hugeImageViewSize: bounds.size, coverImageSize: coverImageSize, imageID: options.imageID, placeholderImage: options.placeholderImage)
        tileCacheManager.delegate = self
        let imageCacheIdentifier = tileCacheManager.imageCacheIdentifier
        hugeImageScrollView.configure(placeholderImage: options.placeholderImage, tileCacheManager: tileCacheManager, hasAlpha: options.imageHasAlpha,
                                      fullImageSize: options.fullImageSize, coverImageSize: coverImageSize, imageCacheIdentifier: imageCacheIdentifier)
        return imageCacheIdentifier
    }

}

extension HugeImageView: TileCacheManagerDelegate {

    func tileCacheManagerDidFinishDownloadingHighResolutionImage(_ tileCacheManager: TileCacheManager, withResult result: Result<URL, HugeImageDownloadError>) {
        DispatchQueue.main.async {
            self.delegate?.hugeImageViewDidFinishDownloadingImage(self, result: result)
        }
    }

}

extension HugeImageView: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return hugeImageScrollView.viewForZooming
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.layoutSubviews()
    }

}
