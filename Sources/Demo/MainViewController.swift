
import UIKit

class MainViewController: UIViewController, StoryboardLoadable {

    @IBAction func didSelectLandscapeImage(_ sender: Any) {
        let hugeImageViewController = HugeImageViewController.initFromStoryboard()
        let imageURL = URL(string: "https://www.nasa.gov/sites/default/files/images/529425main_pia13932-full_full.jpg")!
        let placeholderImage = UIImage(named: "StarsGatherSmall")!
        let fullImageSize = CGSize(width: 6000, height: 3375)
        show(hugeImageViewController, sender: self)
        hugeImageViewController.load(imageURL: imageURL, placeholderImage: placeholderImage, imageSize: fullImageSize)
    }

}
