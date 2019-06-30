
import UIKit

class HugeImageViewController: UIViewController {

    @IBOutlet weak var hugeImageView: HugeImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        let url = URL(string: "https://www.nasa.gov/sites/default/files/images/529425main_pia13932-full_full.jpg")!
        let placeholderImage = UIImage(named: "StarsGatherSmall")!
        hugeImageView.delegate = self
        loadingIndicator.startAnimating()
        let fullImageSize = CGSize(width: 6000,height: 3375)

        hugeImageView.configure(highResolutionImageRemoteURL: url, imageID: "StarsGather", placeholderImage: placeholderImage, fullImageSize: fullImageSize)
    }

    private func stopLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
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
