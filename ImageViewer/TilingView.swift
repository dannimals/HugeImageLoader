
import UIKit

class TilingView: UIView {

    private let tileManager: TileManager
    private var tileBounds: CGRect?
    private let tileSize = CGSize(width: 500, height: 500)
    private let hasAlpha: Bool

    override static var layerClass: AnyClass {
        return CATiledLayer.self
    }

    override var contentScaleFactor: CGFloat {
        didSet {
            super.contentScaleFactor = 1
        }
    }

    required init(tileManager: TileManager, hasAlpha: Bool) {
        // TODO: Optimize for small images
        self.tileManager = tileManager
        self.hasAlpha = hasAlpha
        super.init(frame: tileManager.imageFrame)

        configureTiledLayer()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.tileBounds = bounds
    }

    func configureTiledLayer() {
        guard let tiledLayer = layer as? CATiledLayer else { return }
        tiledLayer.levelsOfDetail = 7
        tiledLayer.levelsOfDetailBias = 3
        tiledLayer.tileSize = tileSize

        guard hasAlpha, let checkerboard = UIImage.checkerboard else { return }
        tiledLayer.isOpaque = false
        tiledLayer.backgroundColor = UIColor(patternImage: checkerboard).cgColor
    }

    func clearImageCache() {
        tileManager.clearImageCache()
    }

    override func draw(_ rect: CGRect) {
        guard let currentContext = UIGraphicsGetCurrentContext(),
            let tileBounds = tileBounds, tileBounds != CGRect.zero
            else { return }

        let scale: CGFloat = currentContext.ctm.a
        var tileSize = self.tileSize
        tileSize.width /= scale
        tileSize.height /= scale

        let firstCol = Int(floor(rect.minX / tileSize.width))
        let lastCol = Int(floor((rect.maxX - 1) / tileSize.width))
        let firstRow = Int(floor(rect.minY / tileSize.height))
        let lastRow = Int(floor((rect.maxY - 1) / tileSize.height))
        guard lastRow >= firstRow && lastCol >= firstCol else { return }
        for row in firstRow...lastRow {
            for col in firstCol...lastCol {
                guard let tile = tileManager.tileFor(size: tileSize, scale: scale, rect: rect, row: row, col: col) else { return }

                var tileRect = CGRect(x: tileSize.width * CGFloat(col), y: tileSize.height * CGFloat(row), width: tileSize.width, height: tileSize.height)
                tileRect = tileBounds.intersection(tileRect)
                tile.draw(in: tileRect)

                //                if true {
                //                    scale == 4 ? UIColor.red.set() : UIColor.white.set()
                //                    currentContext.setLineWidth(6.0 / scale)
                //                    currentContext.stroke(tileRect)
                //                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension UIImage {

    static var checkerboard: UIImage? {
        let side: CGFloat = 20
        let size = CGSize(width: side, height: side)
        UIGraphicsBeginImageContext(size)
        UIColor.white.setFill()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        var box = CGRect(x: 0, y: 0, width: side / 2, height: side / 2)
        let alternateColor = UIColor(white: 0.8, alpha: 1)
        alternateColor.setFill()
        UIRectFill(box)
        box.origin = CGPoint(x: side / 2, y: side / 2)
        UIRectFill(box)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

