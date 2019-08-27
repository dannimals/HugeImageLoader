
import UIKit

extension UIScrollView {

    func zoomToPoint(_ zoomPoint: CGPoint, animated: Bool = true) {
        let zoomRect = CGRect(origin: zoomPoint, size: .zero)
        let currentMaximumScale = maximumZoomScale
        maximumZoomScale = 1
        zoom(to: zoomRect, animated: true)
        maximumZoomScale = currentMaximumScale
    }

}
