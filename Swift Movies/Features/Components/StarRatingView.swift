import UIKit

class StarRatingView: UIView {
    private let size: Double
    private let rating: Double
    
    init(size: Double, rating: Double) {
            self.size = size
            self.rating = rating
            super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
            setupView()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let starImageView = UIImageView(image: UIImage(systemName: Constants.Images.starFill))
        starImageView.contentMode = .scaleAspectFill
        starImageView.tintColor = .systemGray
        
        let starFilledMask = UIView()
        starFilledMask.backgroundColor = .systemYellow
        starFilledMask.frame = CGRect(x: 0, y: 0,
                                      width: size * CGFloat(rating) / 10,
                                      height: size)
        
        let starImageViewFilled = UIImageView(image: UIImage(systemName: Constants.Images.starFill))
        starImageViewFilled.contentMode = .scaleAspectFill
        starImageViewFilled.tintColor = .systemYellow
        starImageViewFilled.mask = starFilledMask
        
        let ratingLabel = UILabel()
        ratingLabel.text = String(format: "%.1f", rating) + " / 10"
        ratingLabel.font = .systemFont(ofSize: 20)
        ratingLabel.textColor = .black
        ratingLabel.textAlignment = .left
        
        addSubview(starImageView)
        addSubview(starImageViewFilled)
        addSubview(ratingLabel)
        starImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(size)
        }
        starImageViewFilled.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(size)
        }
        ratingLabel.snp.makeConstraints { make in
            make.leading.equalTo(starImageView.snp.trailing).offset(12)
            make.centerY.equalTo(starImageView.snp.centerY)
        }
    }
}
