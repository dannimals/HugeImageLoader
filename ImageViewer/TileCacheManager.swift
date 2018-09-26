
import UIKit

protocol TiledImagesFileManagerDelegate: class {

    func highResolutionImageDidSaveToDisk()
    func highResolutionImageDidFailSaveToDisk()
}

class TileCacheManager: NSObject {

    private let fileManager = FileManager.default
    private var tiledImagesPathName: String
    private var highResImagePathName: String
    private var imageID: String
    private let cacheDirectoryURL: URL

    weak var delegate: TiledImagesFileManagerDelegate?

    var finishedDownloadingHighResImage = false

    var highResImage: CGImage? {
        guard let highResPathURL = highResPathURL,
            let dataProvider = CGDataProvider(url: highResPathURL as CFURL),
            let highResImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return nil }
        return highResImage
    }

    private var highResPathURL: URL? {
        let highResComponent = "\(imageID)_\(highResImagePathName)"
        return urlPathByAppending(pathComponent: highResComponent)
    }

    init(cacheDirectoryURL: URL, imageID: String, tiledImagesPathName: String = "TiledImages", highResImagePathName: String = "HighResImage") {
        self.tiledImagesPathName = tiledImagesPathName
        self.highResImagePathName = highResImagePathName
        self.imageID = imageID
        self.cacheDirectoryURL = cacheDirectoryURL
        super.init()

        setupImageCacheDirectory()
    }

    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()

    func downloadHighResImageToDisk(_ url: URL) {
        finishedDownloadingHighResImage = false

        let task = urlSession.downloadTask(with: url) { [weak self] (tempFileURL, urlResponse, error) in
            defer { self?.finishedDownloadingHighResImage = true }
            guard let urlResponse = urlResponse as? HTTPURLResponse,
                (200...299).contains(urlResponse.statusCode),
                let localHighResImageURL = self?.highResPathURL,
                let tempFileURL = tempFileURL else {
                    DispatchQueue.main.async { self?.delegate?.highResolutionImageDidFailSaveToDisk() }
                    print ("error downloading high res image to disk")
                    return
            }
            do {
                try FileManager.default.moveItem(at: tempFileURL, to: localHighResImageURL)
                DispatchQueue.main.async { self?.delegate?.highResolutionImageDidSaveToDisk() }
            } catch {
                DispatchQueue.main.async { self?.delegate?.highResolutionImageDidFailSaveToDisk() }
                print ("error moving high res image to folder: \(error)")
            }
        }
        task.resume()
    }

    private func pathNameFor(prefix: String, row: Int, col: Int) -> String {
        return "\(prefix)-\(row)-\(col)"
    }

    func store(imageData: Data, toPathURL pathURL: URL) {
        try? imageData.write(to: pathURL)
    }

    func fileExists(atPath path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }

    func urlPathByAppending(pathComponent: String) -> URL? {
        return dataCacheDirectory?.appendingPathComponent(pathComponent)
    }

    private lazy var dataCacheDirectory: URL? = {
        return cacheDirectoryURL.appendingPathComponent(tiledImagesPathName)
    }()

    private func setupImageCacheDirectory() {
        guard let dataCacheDirectoryPath = dataCacheDirectory?.path, !fileManager.fileExists(atPath: dataCacheDirectoryPath) else {
            clearImageCache()
            return
        }
        try? fileManager.createDirectory(atPath: dataCacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
    }

    func clearImageCache() {
        guard let dataCacheDirectoryPath = dataCacheDirectory?.path,
            let paths = try? fileManager.contentsOfDirectory(atPath: dataCacheDirectoryPath) else { return }
        for path in paths {
            try? removeItem(atPath: urlPathByAppending(pathComponent: path)?.path)
        }
    }

    private func removeItem(atPath path: String?) throws {
        guard let path = path else { return }
        try fileManager.removeItem(atPath: path)
    }

}

