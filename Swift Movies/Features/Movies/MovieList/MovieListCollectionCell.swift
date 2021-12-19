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
        imageView.setImage(from: posterURL)
        titleLabel.text = title
    }
    
    private func setupCell() {
        let outerView = UIView()
        outerView.frame = CGRect(x: 0, y: 0,
                                 width: contentView.bounds.width,
                                 height: contentView.bounds.size.width * 1.6)
        outerView.clipsToBounds = false
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.4
        outerView.layer.shouldRasterize = true
        outerView.layer.rasterizationScale = UIScreen.main.scale
        outerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds,
                                                  cornerRadius: 20).cgPath
        
        imageView.frame = outerView.bounds
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        
        contentView.addSubview(outerView)
        contentView.addSubview(titleLabel)
        outerView.addSubview(imageView)
        outerView.snp.makeConstraints { make in
            make.top.leading.trailing.width.centerX.equalToSuperview()
            make.height.equalTo(contentView.bounds.size.width * 1.6)
        }
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
    }
}
