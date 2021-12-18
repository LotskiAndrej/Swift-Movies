import UIKit

extension UIView {
    // Adds a gradient to the front of view from array of colors
    func setForegroundGradient(colors: [UIColor], frame: CGRect) {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map { $0.cgColor }
        layer.addSublayer(gradient)
    }
}
