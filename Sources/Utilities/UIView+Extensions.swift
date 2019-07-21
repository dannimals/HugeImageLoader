
import UIKit

extension UIView {

    func constrainSizeToBounds(desiredSize: CGSize) -> CGSize {
        let aspectRatio = desiredSize.width / desiredSize.height
        let width = min(aspectRatio * bounds.height, bounds.width)
        let height = min(width / aspectRatio, bounds.height)
        return CGSize(width: width, height: height)
    }

    func constrainSizeToBounds(_ bounds: CGRect, aspectRatio: CGFloat) -> CGSize {
        let width = min(aspectRatio * bounds.height, bounds.width)
        let height = min(width / aspectRatio, bounds.height)
        return CGSize(width: width, height: height)
    }

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

protocol NibRepresentable: class {}

extension UINib {

    typealias Name = String

}

extension NibRepresentable {

    public static var nibName: UINib.Name { return String(describing: self) }

    public static func instantiateFromNib() -> Self {
        return instantiateFromNib(withName: nibName)
    }

    public static func instantiateFromNib(withName nibName: String) -> Self {
        return Bundle(for: self).loadNibNamed(nibName, owner: self, options: nil)?.first as! Self
    }

}

protocol StoryboardNestable: NibRepresentable {

    var contentView: UIView! { get }

}

extension StoryboardNestable where Self: UIView {

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed(Self.nibName, owner: self, options: [:])
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}


