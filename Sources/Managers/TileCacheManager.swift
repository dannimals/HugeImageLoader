
import UIKit

protocol TileCacheManagerDelegate: class {

    func tileCacheManagerDidFinishDownloadingHighResolutionImage(_ tileCacheManager: TileCacheManager, withResult result: Result<URL, HugeImageDownloadError>)

}

class TileCacheManager: NSObject {

    private(set) var imageCacheIdentifier: ImageCacheIdentifier

    private let fileManager = FileManager.default
    private let tiledImagesPathName = "TiledImages"
    private let _coverImageSize: CGSize?
    private let placeholderImage: UIImage?
    private let imageViewSize: CGSize
    private var downloadManager: DownloadManaging

    weak var delegate: TileCacheManagerDelegate?

    var highResolutionImage: CGImage? {
        guard
            let highResolutionImageLocalPathURL = highResolutionImageLocalPathURL,
            let dataProvider = CGDataProvider(url: highResolutionImageLocalPathURL as CFURL),
            let highResolutionImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) ??
                    CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
            else { return nil }
        return highResolutionImage
    }
    var coverImageSize: CGSize? { return _coverImageSize ?? calculatedCoverImageSize }
    var coverImage: UIImage? {
        guard let coverImageSize = coverImageSize else { return nil }
        cacheCoverImageTileIfNeeded(ofSize: coverImageSize)
        return UIImage(contentsOfFile: coverImageTilePathURL.path) ?? placeholderImage
    }
    var fullImageSize: CGSize {
        guard let highResolutionImage = highResolutionImage else { return .zero }
        return CGSize(width: highResolutionImage.width, height: highResolutionImage.height)
    }

    private lazy var highResolutionImageLocalPathURL: URL? = {
        let highResComponent = "\(String(describing: imageCacheIdentifier.id))_highResolutionImage"
        return urlPathByAppending(pathComponent: highResComponent)
    }()
    private lazy var coverImageTilePathURL: URL = {
        return urlPathByAppending(pathComponent: "\(imageCacheIdentifier.id)-coverImage-\(imageViewSize.width)x\(imageViewSize.height)")!
    }()
    private lazy var cacheDirectoryURL: URL? = {
        let cacheDirectoryURL = DataCacheURL.dataCacheDirectoryURL(identifier: "HugeImageLoaderUser")
        return cacheDirectoryURL?.appendingPathComponent("TiledImages")
    }()
    private var calculatedCoverImageSize: CGSize? {
        guard let highResolutionImage = highResolutionImage else { return nil }
        let fullImageSize = CGSize(width: highResolutionImage.width, height: highResolutionImage.height)
        let scale = ceil(max(2, min(3, fullImageSize.width / imageViewSize.width)))
        let size = CGSize(width: imageViewSize.width * scale, height: imageViewSize.height * scale)
        return fullImageSize.constrainToSize(size)
    }

    init(highResolutionImageRemoteURL: URL,
         imageViewSize: CGSize,
         options: HugeImageOptions? = nil,
         downloadManager: DownloadManaging? = nil) {
        self.imageCacheIdentifier = ImageCacheIdentifier(id: options?.imageID ?? UUID().uuidString)
        self.imageViewSize = imageViewSize
        self._coverImageSize = options?.placeholderImage.size
        self.placeholderImage = options?.placeholderImage
        self.downloadManager = downloadManager ?? DownloadManager()

        super.init()

        setupCache()
        self.downloadManager.delegate = self
        self.downloadManager.downloadImageFromURL(highResolutionImageRemoteURL)
    }

    func urlPathFor(prefix: String, row: Int, col: Int) -> URL? {
        return urlPathByAppending(pathComponent: "\(prefix)-\(row)-\(col)")
    }

    func store(imageData: Data, toPathURL pathURL: URL) {
        try? imageData.write(to: pathURL)
    }

    func fileExists(atPath path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }

    private func urlPathByAppending(pathComponent: String) -> URL? {
        return cacheDirectoryURL?.appendingPathComponent(pathComponent)
    }

    private func cacheCoverImageTileIfNeeded(ofSize imageSize: CGSize) {
        guard !fileExists(atPath: coverImageTilePathURL.path),
            let highResolutionImage = highResolutionImage else { return }

        guard let resizedImage = highResolutionImage.resizedImage(toSize: imageSize),
            let imageData = UIImagePNGRepresentation(resizedImage) else { return }
        store(imageData: imageData, toPathURL: coverImageTilePathURL)
    }

    private func setupCache() {
        guard let dataCacheDirectoryPath = cacheDirectoryURL?.path, !fileManager.fileExists(atPath: dataCacheDirectoryPath) else {
            clearImageCache()
            return
        }
        try? fileManager.createDirectory(atPath: dataCacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
    }

    private func clearImageCache() {
        guard
            let dataCacheDirectoryPath = cacheDirectoryURL?.path,
            let paths = try? fileManager.contentsOfDirectory(atPath: dataCacheDirectoryPath) else { return }

        paths.forEach { try? removeItem(atPath: urlPathByAppending(pathComponent: $0)?.path)}
    }

    private func removeItem(atPath path: String?) throws {
        guard let path = path else { return }
        try fileManager.removeItem(atPath: path)
    }

}

extension TileCacheManager: DownloadManagerDelegate {

    func downloadManagerDidFinishDownloading(_ downloadManager: DownloadManaging, withResult result: Result<URL, HugeImageDownloadError>) {
        guard case let .success(tempURL) = result else {
            delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(self, withResult: result)
            return
        }
        guard let highResolutionImageLocalPathURL = highResolutionImageLocalPathURL else {
            delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(self, withResult: .failure(.failedToSetupLocalCache))
            return
        }
        moveItem(at: tempURL, to: highResolutionImageLocalPathURL)
    }

    private func moveItem(at tempFileURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
            delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(self, withResult: .success(destinationURL))
        } catch {
            delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(self, withResult: .failure(.failedToMoveItemToLocalCache))
        }
    }

}
