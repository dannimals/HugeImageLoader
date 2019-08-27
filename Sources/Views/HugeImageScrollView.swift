
import UIKit
import AudioToolbox

class HugeImageScrollView: UIScrollView, ViewStylePreparing {

    private enum Constant {
        static let retinaScale: CGFloat = UIScreen.main.scale
        static let animationDuration: TimeInterval = 0.2
    }

    var drawingContainerView: UIView? { return tilingView }
    var viewForZooming: UIView { return tilingView }

    private(set) var tilingView: TilingView!
    private var isZoomedToFit: Bool { return zoomScale == zoomScaleToFit }
    private var zoomScaleToFit: CGFloat { return min(bounds.size.width / placeholderImageSize.width,
                                                     bounds.size.height / placeholderImageSize.height) }
    private var placeholderImageSize: CGSize = .zero
    private var placeholderImage: UIImage?
    private var tileCacheManager: TileCacheManager!
    private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer!
    private var shouldReloadTilingView = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        centerImageView()
    }

    func configure(tileCacheManager: TileCacheManager,
                   imageCacheIdentifier: ImageCacheIdentifier,
                   options: HugeImageOptions? = nil) {
        removeTilingViewIfNeeded()
        self.tileCacheManager = tileCacheManager
        shouldReloadTilingView = options == nil
        guard let options = options else { return }
        self.placeholderImageSize = options.placeholderImage.size
        let coverImageAspectRatio = options.placeholderImage.size.width / options.placeholderImage.size.height
        setupTilingView(placeholderImage: options.placeholderImage, tileCacheManager: tileCacheManager, hasAlpha: options.imageHasAlpha,
                        coverImageAspectRatio: coverImageAspectRatio, imageCacheIdentifier: imageCacheIdentifier)
        layoutIfNeeded()
        setMaxMinZoomScale(forFileSize: options.fullImageSize)
    }

    func reloadTilingViewIfNeeded() {
        // FIXME: Need a more sophisticated check tp ensure downloaded image in tile manager is the right image
        guard shouldReloadTilingView else { return }
        let tileGenerator = TileGenerator(cacheManager: tileCacheManager)
        guard let coverImage = tileGenerator.coverImage else { return }
        let tilingViewFrame = CGRect(origin: .zero, size: coverImage.size)
        tilingView = TilingView(frame: .zero, tileGenerator: tileGenerator, hasAlpha: true, coverImageSize: coverImage.size)
        tilingView.frame = tilingViewFrame
        addSubview(tilingView)
        layoutIfNeeded()
        setMaxMinZoomScale(forFileSize: tileGenerator.fullImageSize)
    }

    private func setupTilingView(placeholderImage: UIImage, tileCacheManager: TileCacheManager, hasAlpha: Bool,
                                 coverImageAspectRatio: CGFloat, imageCacheIdentifier: ImageCacheIdentifier) {
        let tileGenerator = TileGenerator(cacheManager: tileCacheManager)
        let tilingViewFrame = CGRect(origin: .zero, size: placeholderImage.size)
        tilingView = TilingView(frame: .zero, tileGenerator: tileGenerator, hasAlpha: hasAlpha, coverImageSize: placeholderImage.size)
        tilingView.frame = tilingViewFrame
        addSubview(tilingView)
    }

    private func removeTilingViewIfNeeded() {
        guard let tilingView = tilingView else { return }

        tilingView.removeFromSuperview()
        self.tilingView = nil
    }

    func configurePanGestureMinNumberOfTouches(_ minNumberOfTouches: Int) {
        panGestureRecognizer.minimumNumberOfTouches = minNumberOfTouches
    }

    func setup() {
        setupDoubleTapGestureRecognizer()
    }

    func setupViews() {
        setupScrollView()
    }

    private func setupScrollView() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }

    private func setupDoubleTapGestureRecognizer() {
        doubleTapGestureRecognizer = UITapGestureRecognizer()
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.addTarget(self, action: #selector(didDoubleTap))
        addGestureRecognizer(doubleTapGestureRecognizer)
    }

    private func setMaxMinZoomScale(forFileSize fileSize: CGSize) {
        let bounds = UIScreen.main.bounds
        maximumZoomScale = calculateMaximumZoomScale(forFileSize: fileSize)
        minimumZoomScale = 0.125

        if tilingView.bounds.size.width > bounds.width {
            let scale = bounds.width / tilingView.bounds.size.width
            minimumZoomScale = min(minimumZoomScale, scale)
        }
        if tilingView.bounds.width < bounds.width && tilingView.bounds.height < bounds.height {
            minimumZoomScale = zoomScaleToFit
            maximumZoomScale = zoomScaleToFit
        }
        zoomScale = zoomScaleToFit
    }

    private func calculateMaximumZoomScale(forFileSize fileSize: CGSize) -> CGFloat {
        let expectedWidthZoomScale = ((fileSize.width / Constant.retinaScale) / bounds.width)
        let expectedHeightZoomScale = ((fileSize.height / Constant.retinaScale) / bounds.height)
        return max(expectedWidthZoomScale, expectedHeightZoomScale, 2)
    }

    private func centerImageView() {
        guard let tilingView = self.tilingView else { return }
        tilingView.frame = centerFrame(viewToCenter: tilingView)
    }

    private func zoomToFit(animated: Bool = true) {
        setZoomScale(zoomScaleToFit, animated: animated)
        tilingView.setNeedsDisplay()
    }

    @objc
    private func didDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if isZoomedToFit {
            let location = gestureRecognizer.location(in: self)
            guard tilingView.frame.contains(location) else { return }
            let zoomPoint = gestureRecognizer.location(in: tilingView)
            zoomToPoint(zoomPoint)
        } else {
            zoomToFit()
        }
    }

}
