import UIKit

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        let imageView = UIImageView(image: UIImage(systemName: Constants.Images.exclamationMarkCircle))
        imageView.tintColor = .black
        
        let errorMessageLabel = UILabel()
        errorMessageLabel.text = message
        errorMessageLabel.font = .systemFont(ofSize: 20)
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.textColor = .black
        errorMessageLabel.textAlignment = .center
        
        container.addSubview(imageView)
        container.addSubview(errorMessageLabel)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.centerX.equalToSuperview()
        }
        errorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
        }

        backgroundView = container
    }

    func restore() {
        backgroundView = nil
    }
}
