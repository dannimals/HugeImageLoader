
import UIKit

class HugeImageViewController: UIViewController, StoryboardLoadable {

    @IBOutlet weak var hugeImageView: HugeImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
    }

    func load(imageURL: URL, placeholderImage: UIImage, imageSize: CGSize) {
        hugeImageView.delegate = self
        loadingIndicator.startAnimating()

        hugeImageView.load(highResolutionImageRemoteURL: imageURL, imageID: "StarsGather", placeholderImage: placeholderImage, fullImageSize: imageSize)
    }

    private func stopLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}

extension HugeImageViewController: HugeImageViewDelegate {

    func hugeImageViewDidFinishDownloadingImage(_ hugeImageView: HugeImageView, result: Result<URL, HugeImageDownloadError>) {
        stopLoading()
        guard case let .failure(error) = result else { return }
        self.handleError(error)
    }

    private func handleError(_ error: HugeImageDownloadError) {
        var message = ""
        switch error {
        case let .failedToDownloadItem(error: error):
            message = "Failed to download item with error \(String(describing: error))"
        case .failedToMoveItemToLocalCache:
            message = "Failed to move downloaded image to local cache"
        case .failedToSetupLocalCache:
            message = "Failed to set up local cache"
        case .missingLocalCacheURL:
            message = "Missing local cache URL"
        }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        show(alert, sender: nil)
    }

}
