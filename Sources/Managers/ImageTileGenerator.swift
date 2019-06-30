
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

    private func pathNameFor(prefix: String, row: Int, col: Int) -> String {
        return "\(prefix)-\(row)-\(col)"
    }

    func tileFor(size: CGSize, scale: CGFloat, rect: CGRect, row: Int, col: Int) -> UIImage? {
        let prefix = "\(imageID)_\(String(Int(scale * 1000)))"
        let pathComponent = pathNameFor(prefix: prefix, row: row, col: col)

        guard let filePath = tileCacheManager.urlPathByAppending(pathComponent: pathComponent) else { return nil }

        if !tileCacheManager.fileExists(atPath: filePath.path) {
            var optimalImage = placeholderImage.cgImage
            if scale * 1000 >= 4000 {
                optimalImage = tileCacheManager.highResolutionImage ?? placeholderImage.cgImage
            }
            guard let cgImage = optimalImage else { return nil }

            let mappedRect = mappedRectForImage(cgImage, rect: rect)
            saveTile(forImage: cgImage, ofSize: size, forRect: mappedRect, usingPrefix: prefix, forRow: row, forCol: col)
        }

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

    private func saveTile(forImage image: CGImage, ofSize tileSize: CGSize, forRect rect: CGRect, usingPrefix prefix: String, forRow row: Int, forCol col: Int) {
        let pathComponent = pathNameFor(prefix: prefix, row: row, col: col)
        guard let tileImage = image.cropping(to: rect),
            let imageData = UIImagePNGRepresentation(UIImage(cgImage: tileImage)),
            let pathURL = tileCacheManager.urlPathByAppending(pathComponent: pathComponent) else { return }
        tileCacheManager.store(imageData: imageData, toPathURL: pathURL)
    }

}
