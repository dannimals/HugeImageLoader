
import UIKit

extension UIView {

    func centerFrame(viewToCenter: UIView) -> CGRect {
        let boundsSize = bounds.size
        var frameToCenter = viewToCenter.frame

        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        return frameToCenter
    }

}
