
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

public class HugeImageView: UIView, StoryboardNestable, ViewStylePreparing {

    public weak var delegate: HugeImageViewDelegate?

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var hugeImageScrollView: HugeImageScrollView!

    public var drawingView: UIView? {
        return hugeImageScrollView.drawingContainerView
    }

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

    public func load(highResolutionImageRemoteURL: URL, imageID: String, placeholderImage: UIImage, fullImageSize: CGSize, imageHasAlpha: Bool = true) {
        let tileCacheManager = TileCacheManager(highResolutionImageRemoteURL: highResolutionImageRemoteURL, imageID: imageID)
        tileCacheManager.delegate = self
        hugeImageScrollView.configure(placeholderImage: placeholderImage, imageID: imageID, tileCacheManager: tileCacheManager, hasAlpha: imageHasAlpha, fullImageSize: fullImageSize)
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
