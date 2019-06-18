
import UIKit

protocol TileCacheManagerDelegate: class {

    func tileCacheManagerDidFinishDownloadingHighResolutionImage(_ tileCacheManager: TileCacheManager, withResult result: Result<URL, HugeImageDownloadError>)

}

class TileCacheManager: NSObject {

    private let fileManager = FileManager.default
    private let tiledImagesPathName = "TiledImages"
    private let imageID: String

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

    init(highResolutionImageRemoteURL: URL, imageID: String) {
        self.imageID = imageID

        super.init()

        setupCache()
        downloadHighResolutionImageFromURL(url: highResolutionImageRemoteURL)
    }

    private lazy var highResolutionImageLocalPathURL: URL? = {
        let highResComponent = "\(String(describing: imageID))_highResolutionImage"
        return urlPathByAppending(pathComponent: highResComponent)
    }()

    private lazy var cacheDirectoryURL: URL? = {
        let cacheDirectoryURL = DataCacheURL.dataCacheDirectoryURL(identifier: "HugeImageLoaderUser")
        return cacheDirectoryURL?.appendingPathComponent("TiledImages")
    }()

    private lazy var downloadSession: URLSession = {
        let configuration: URLSessionConfiguration = .default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()

    func urlPathByAppending(pathComponent: String) -> URL? {
        return cacheDirectoryURL?.appendingPathComponent(pathComponent)
    }

    func store(imageData: Data, toPathURL pathURL: URL) {
        try? imageData.write(to: pathURL)
    }

    func fileExists(atPath path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }

    private func downloadHighResolutionImageFromURL(url: URL) {
        let task = downloadSession.downloadTask(with: url) { [weak self] (tempFileURL, urlResponse, error) in
            guard let strongSelf = self else { return }

            guard
                let urlResponse = urlResponse as? HTTPURLResponse,
                (200...299).contains(urlResponse.statusCode) else {
                    strongSelf.delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(strongSelf, withResult: .failure(.failedToDownloadItem(error: error)))
                    return
            }

            guard
                let localHighResImageURL = self?.highResolutionImageLocalPathURL,
                let tempFileURL = tempFileURL else {
                    strongSelf.delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(strongSelf, withResult: .failure(.missingLocalCacheURL))
                    return
            }
            strongSelf.moveItem(at: tempFileURL, to: localHighResImageURL)
        }
        task.resume()
    }

    private func setupCache() {
        guard let dataCacheDirectoryPath = cacheDirectoryURL?.path, !fileManager.fileExists(atPath: dataCacheDirectoryPath) else {
            clearImageCache()
            return
        }
        try? fileManager.createDirectory(atPath: dataCacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
    }

    private func moveItem(at tempFileURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
            delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(self, withResult: .success(destinationURL))
        } catch {
            delegate?.tileCacheManagerDidFinishDownloadingHighResolutionImage(self, withResult: .failure(.failedToMoveItemToLocalCache))
        }
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

