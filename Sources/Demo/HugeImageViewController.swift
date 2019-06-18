
import UIKit

class HugeImageViewController: UIViewController {

    @IBOutlet weak var hugeImageView: HugeImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        let url = URL(string: "https://frameio-uploads-production.s3-accelerate.amazonaws.com/uploads/c8f99f0f-7475-4499-b068-d1b3a267f27e/original.jpg?response-content-disposition=attachment%3B%20filename%3D%22StarsGatherPIA13932.jpg%22%3B%20filename%2A%3D%22StarsGatherPIA13932.jpg%22&x-amz-meta-project_id=1338b3bb-8471-4380-9a04-fe3e27a9ac29&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIHKSS2IP3JTIPKYQ%2F20190616%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190616T210137Z&X-Amz-Expires=172800&X-Amz-SignedHeaders=host&X-Amz-Signature=189ee57d68953d2be0241df54c63e611943d34a3050bd34f8c3554b5d9fd5212")!
        let placeholderImage = UIImage(named: "StarsGatherSmall")!
        hugeImageView.delegate = self
        loadingIndicator.startAnimating()
        let fullImageSize = CGSize(width: 16000, height: 9000)

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
