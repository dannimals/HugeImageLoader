
import Foundation

public enum DataCacheURL {

    private static let cachesDirectoryURL: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    private static let dataCacheDirectoryName: String = "com.HugeImageLoader.DataCache"
    private static let dataCacheDirectoryBaseURL: URL? = cachesDirectoryURL?.appendingPathComponent(dataCacheDirectoryName)

    public static func dataCacheDirectoryURL(identifier: String) -> URL? {
        return dataCacheDirectoryBaseURL?.appendingPathComponent(identifier)
    }

}
