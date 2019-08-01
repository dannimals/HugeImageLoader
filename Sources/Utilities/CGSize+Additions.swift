
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
        let aspectRatio = maxSize.width / maxSize.height
        let widthRatio  = maxSize.width / width
        let heightRatio = maxSize.height / height

        var width: CGFloat = 0
        var height: CGFloat = 0
        if widthRatio > heightRatio {
            width = min(width, maxSize.width)
            height = width / aspectRatio
        } else {
            height = min(height, maxSize.height)
            width = height * aspectRatio
        }
        return CGSize(width: ceil(width), height: ceil(height))

    }

}
