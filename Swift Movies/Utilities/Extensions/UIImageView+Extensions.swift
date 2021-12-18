import UIKit
import Kingfisher

extension UIImageView {
    // Constructs the URL, loads the image either from cache or network
    func setImage(from posterURL: String) {
        guard let url = URL(string: Constants.Network.imageURL + posterURL) else { return }
        
        // Creates a custom cache key for every image using URL
        let cache = ImageCache.default
        let isCached = cache.isCached(forKey: posterURL)
        
        // If cached, display a placeholder
        // while image is being retrieved from memory
        if isCached {
            image = UIImage.placeholder()
            cache.retrieveImage(forKey: posterURL) { result in
                switch result {
                case .success(let value):
                    self.image = value.image
                case .failure:
                    break
                }
            }
        } else {
            // If not cached, download image and store in cache
            let resource = ImageResource(downloadURL: url, cacheKey: posterURL)
            kf.setImage(
                with: resource,
                placeholder: UIImage.placeholder()
            )
        }
    }
}
