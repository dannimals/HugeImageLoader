
import UIKit

extension CGSize {

    func constrainedToAspectRatio(_ aspectRatio: CGFloat) -> CGSize {
        let targetWidth = min(width, aspectRatio * height)
        let targetHeight = min(height, targetWidth / aspectRatio)

        if targetWidth > targetHeight {
            let width = ceil(targetHeight * aspectRatio)
            return CGSize(width: width, height: ceil(targetHeight))
        } else {
            let height = ceil(targetWidth / aspectRatio)
            return CGSize(width: targetWidth, height: ceil(height))
        }
    }
}
