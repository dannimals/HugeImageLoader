
import UIKit

class TilingView: UIView {

    private let tileGenerator: TileGenerator
    private var tileBounds: CGRect?
    private let tileSize = CGSize(width: 400, height: 400)
    private let levelsOfDetail = 7
    private let levelsOfDetailBias = 3
    private let hasAlpha: Bool

    override static var layerClass: AnyClass {
        return CATiledLayer.self
    }

    override var contentScaleFactor: CGFloat {
        didSet {
            super.contentScaleFactor = 1
        }
    }

    required init(tileGenerator: TileGenerator, hasAlpha: Bool) {
        self.tileGenerator = tileGenerator
        self.hasAlpha = hasAlpha

        super.init(frame: tileGenerator.imageFrame)

        configureTiledLayer()
    }

    func configureTiledLayer() {
        guard let tiledLayer = layer as? CATiledLayer else { return }
        tiledLayer.levelsOfDetail = levelsOfDetail
        tiledLayer.levelsOfDetailBias = levelsOfDetailBias
        tiledLayer.tileSize = tileSize

        guard hasAlpha, let checkerboard = UIImage.checkerboard else { return }

        tiledLayer.isOpaque = false
        tiledLayer.backgroundColor = UIColor(patternImage: checkerboard).cgColor
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.tileBounds = bounds
    }

    override func draw(_ rect: CGRect) {
        guard
            let currentContext = UIGraphicsGetCurrentContext(),
            let tileBounds = tileBounds, tileBounds != .zero else { return }

        let scale: CGFloat = currentContext.ctm.a
        var tileSize = self.tileSize
        tileSize.width /= scale
        tileSize.height /= scale

        let firstColumn = Int(floor(rect.minX / tileSize.width))
        let lastColumn = Int(floor((rect.maxX - 1) / tileSize.width))
        let firstRow = Int(floor(rect.minY / tileSize.height))
        let lastRow = Int(floor((rect.maxY - 1) / tileSize.height))
        guard lastRow >= firstRow && lastColumn >= firstColumn else { return }
        for row in firstRow...lastRow {
            for col in firstColumn...lastColumn {
                guard let tile = tileGenerator.tileFor(size: tileSize, scale: scale, rect: rect, row: row, col: col) else { return }

                var tileRect = CGRect(x: tileSize.width * CGFloat(col), y: tileSize.height * CGFloat(row), width: tileSize.width, height: tileSize.height)
                tileRect = tileBounds.intersection(tileRect)
                tile.draw(in: tileRect)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
