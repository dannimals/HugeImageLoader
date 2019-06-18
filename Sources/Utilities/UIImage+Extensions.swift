
import UIKit

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
