
import UIKit

protocol StoryboardLoadable {

    static func initFromStoryboard(_ storyboardName: String) -> Self

}

extension StoryboardLoadable where Self: UIViewController {

    static func initFromStoryboard(_ storyboardName: String = "Main") -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}
