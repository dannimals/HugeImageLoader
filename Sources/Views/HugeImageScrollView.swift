
import UIKit
import AudioToolbox

class HugeImageScrollView: UIScrollView {

    private enum Constant {
        static let retinaScale: CGFloat = UIScreen.main.scale
    }

    var drawingContainerView: UIView? {
        return tilingView
    }
    var viewForZooming: UIView? { return tilingView }

    private(set) var tilingView: TilingView!
    private var isZoomedToFit: Bool {
        return zoomScaleToFit == zoomScale
    }
    private var zoomScaleToFit: CGFloat {
        return min(bounds.size.width / placeholderImageSize.width, bounds.size.height / placeholderImageSize.height)
    }
    private var placeholderImageSize: CGSize = CGSize(width: 1, height: 1)

    private var placeholderImage: UIImage?
    private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

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

    func configure(placeholderImage: UIImage,
                   imageID: String,
                   tileCacheManager: TileCacheManager,
                   hasAlpha: Bool,
                   fullImageSize: CGSize) {
        self.placeholderImageSize = placeholderImage.size
        setupTilingView(placeholderImage: placeholderImage, imageID: imageID, tileCacheManager: tileCacheManager, hasAlpha: hasAlpha)
        setMaxMinZoomScale(forFileSize: fullImageSize)
    }

    private func setupTilingView(placeholderImage: UIImage, imageID: String, tileCacheManager: TileCacheManager, hasAlpha: Bool) {
        removeTilingViewIfNeeded()
        let tileGenerator = TileGenerator(placeholderImage: placeholderImage, imageID: imageID, cacheManager: tileCacheManager)
        let tilingViewFrame = CGRect(origin: .zero, size: placeholderImage.size)
        tilingView = TilingView(frame: tilingViewFrame, tileGenerator: tileGenerator, hasAlpha: hasAlpha)
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

    private func setup() {
        setupScrollView()
        setupDoubleTapGestureRecognizer()
    }

    private func setMaxMinZoomScale(forFileSize fileSize: CGSize) {
        guard let tilingView = tilingView else { return }

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

    private func zoomToFit() {
        zoomScale = zoomScaleToFit
        layoutIfNeeded()
        delegate?.scrollViewDidZoom?(self)
    }

    @objc
    private func didDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        guard isZoomedToFit else {
            UIView.animate(withDuration: 0.25) {
                self.zoomToFit()
            }
            return
        }
        let location = gestureRecognizer.location(in: tilingView)
        let zoomPoint = (superview ?? self).convert(location, to: self)
        let zoomRect = CGRect(origin: zoomPoint, size: .zero)
        maximumZoomScale = 1
        zoom(to: zoomRect, animated: true)
        maximumZoomScale = 2
    }

}
