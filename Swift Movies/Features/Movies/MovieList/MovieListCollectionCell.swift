import UIKit
import Kingfisher

class MovieListCollectionCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Populates cell with movie poster image url and title
    func populate(posterURL: String, title: String) {
        guard let url = URL(string: Constants.Network.imageURL + posterURL) else { return }
        
        // This creates a UIImage from just a color
        let size = CGSize(width: 100, height: 100)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        UIColor.systemGray5.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Creates a custom cache key for every image using URL
        let cache = ImageCache.default
        let isCached = cache.isCached(forKey: posterURL)
        
        // If cached, display a placeholder
        // while image is being retrieved from memory
        if isCached {
            imageView.image = image
            cache.retrieveImage(forKey: posterURL) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.imageView.image = value.image
                case .failure:
                    break
                }
            }
        } else {
            // If not cached, download image and store in cache
            let resource = ImageResource(downloadURL: url, cacheKey: posterURL)
            imageView.kf.setImage(
                with: resource,
                placeholder: image
            )
        }
        
        titleLabel.text = title
    }
    
    private func setupCell() {
        let outerView = UIView()
        outerView.frame = CGRect(x: 0, y: 0,
                                 width: contentView.bounds.width,
                                 height: contentView.bounds.size.width * (1 / (10 / 16)))
        outerView.clipsToBounds = false
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.4
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds,
                                                  cornerRadius: 20).cgPath
        outerView.layer.shouldRasterize = true
        outerView.layer.rasterizationScale = UIScreen.main.scale
        outerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        imageView.frame = outerView.bounds
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        
        outerView.addSubview(imageView)
        contentView.addSubview(outerView)
        contentView.addSubview(titleLabel)
        outerView.snp.makeConstraints { make in
            make.top.leading.trailing.width.centerX.equalToSuperview()
            make.height.equalTo(contentView.bounds.size.width * (1 / (10 / 16)))
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
    }
}
