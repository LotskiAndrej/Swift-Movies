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
        let url = URL(string: Constants.Network.imageURL + posterURL)
        
        // This creates a UIImage from just a color
        let size = CGSize(width: 100, height: 100)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        UIColor.systemGray5.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.kf.setImage(
            with: url,
            placeholder: image
        )
        titleLabel.text = title
    }
    
    private func setupCell() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.width.centerX.equalToSuperview()
            make.height.equalTo(contentView.bounds.size.width * (1 / (10 / 16)))
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
    }
}
