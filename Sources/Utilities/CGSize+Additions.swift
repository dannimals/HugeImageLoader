
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

    func constrainToSize(_ maxSize: CGSize) -> CGSize {
        let aspectRatio = width / height
        var adjustedWidth: CGFloat = 0
        var adjustedHeight: CGFloat = 0
        if width > height {
            adjustedWidth = min(width, maxSize.width)
            adjustedHeight = adjustedWidth / aspectRatio
        } else {
            adjustedHeight = min(height, maxSize.height)
            adjustedWidth = adjustedHeight * aspectRatio
        }
        return CGSize(width: ceil(adjustedWidth), height: ceil(adjustedHeight))
    }

}
