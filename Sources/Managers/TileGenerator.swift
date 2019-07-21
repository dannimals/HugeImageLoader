
import UIKit

class TileGenerator {

    private let placeholderImage: UIImage
    private let tileCacheManager: TileCacheManager
    private let imageID: String

    init(placeholderImage: UIImage, imageID: String, cacheManager: TileCacheManager) {
        self.placeholderImage = placeholderImage
        self.imageID = imageID
        self.tileCacheManager = cacheManager
    }

    private func urlPathFor(prefix: String, row: Int, col: Int) -> URL? {
        return tileCacheManager.urlPathByAppending(pathComponent: "\(prefix)-\(row)-\(col)")
    }

    var coverImage: UIImage {
        return tileCacheManager.coverImage ?? placeholderImage
    }

    func tileFor(size: CGSize, scale: CGFloat, rect: CGRect, row: Int, col: Int) -> UIImage? {
        let prefix = "\(imageID)_\(String(Int(scale * 1000)))"

        guard let filePath = urlPathFor(prefix: prefix, row: row, col: col) else { return nil }
        guard !tileCacheManager.fileExists(atPath: filePath.path) else {
            return UIImage(contentsOfFile: filePath.path)
        }

        var optimalImage = placeholderImage.cgImage
        if scale * 1000 >= 4000 {
            optimalImage = tileCacheManager.highResolutionImage ?? placeholderImage.cgImage
        }

        guard let cgImage = optimalImage else { return nil }

        let mappedRect = mappedRectForImage(cgImage, rect: rect)
        saveTile(forImage: cgImage, tileSize: size, rect: mappedRect, prefix: prefix, row: row, col: col)
        return UIImage(contentsOfFile: filePath.path)
    }

    private func mappedRectForImage(_ mappedImage: CGImage, rect: CGRect) -> CGRect {
        let scaleX = CGFloat(mappedImage.width) / placeholderImage.size.width
        let scaleY = CGFloat(mappedImage.height) / placeholderImage.size.height

        let mappedX = rect.minX * scaleX
        let mappedY = rect.minY * scaleY
        let mappedWidth = rect.width * scaleX
        let mappedHeight = rect.height * scaleY

        return CGRect(x: mappedX, y: mappedY, width: mappedWidth, height: mappedHeight)
    }

    private func saveTile(forImage image: CGImage, tileSize: CGSize, rect: CGRect, prefix: String, row: Int, col: Int) {
        guard
            let tileImage = image.cropping(to: rect),
            let imageData = UIImagePNGRepresentation(UIImage(cgImage: tileImage)),
            let pathURL = urlPathFor(prefix: prefix, row: row, col: col) else { return }
        tileCacheManager.store(imageData: imageData, toPathURL: pathURL)
    }

}
