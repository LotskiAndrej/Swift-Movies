import UIKit

extension UIImage {
    // Creates a UIImage from just a color
    static func placeholder(color: UIColor = .systemGray5) -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        color.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
