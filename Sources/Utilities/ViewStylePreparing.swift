
import UIKit

protocol ViewStylePreparing {

    func setup()
    func setupColors()
    func setupFonts()
    func setupLayers()
    func setupText()
    func setupImages()
    func setupViews()

}

extension ViewStylePreparing {

    func setup() {
        setupColors()
        setupFonts()
        setupLayers()
        setupText()
        setupImages()
        setupViews()
    }

    func setupColors() {}
    func setupFonts() {}
    func setupLayers() {}
    func setupText() {}
    func setupImages() {}
    func setupViews() {}

}
