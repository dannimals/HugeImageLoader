
import UIKit

extension CGImage {

    func resizedImage(toSize size: CGSize) -> UIImage? {
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(self, in: CGRect(origin: .zero, size: size))

        guard let scaledImage = context?.makeImage() else { return nil }
        return UIImage(cgImage: scaledImage)
    }

}
