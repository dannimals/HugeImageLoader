
import UIKit

class MainViewController: UIViewController, StoryboardLoadable {

    let hugeImageViewController = HugeImageViewController.initFromStoryboard()
    let imageURL = URL(string: "https://www.nasa.gov/sites/default/files/images/529425main_pia13932-full_full.jpg")!

    @IBAction func loadImageWithoutOptions(_ sender: Any) {
        let placeholderImage = UIImage(named: "StarsGatherSmall")!
        let fullImageSize = CGSize(width: 6000, height: 3375)
        show(hugeImageViewController, sender: self)
        hugeImageViewController.load(imageURL: imageURL, placeholderImage: placeholderImage, imageSize: fullImageSize)
    }

    @IBAction func loadImageWithOptions(_ sender: Any) {
        let placeholderImage = UIImage(named: "StarsGatherSmall")!
        let fullImageSize = CGSize(width: 6000, height: 3375)
        let hugeImageOptions = HugeImageOptions(imageID: "starsGatherID", imageHasAlpha: true, placeholderImage: placeholderImage, fullImageSize: fullImageSize)
        show(hugeImageViewController, sender: self)
        hugeImageViewController.load(imageURL: imageURL, withOptions: hugeImageOptions)
    }

}
