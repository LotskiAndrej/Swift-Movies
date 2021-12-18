import UIKit

class FloatingIndicatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    private func setupView() {
        let container = UIView()
        container.backgroundColor = .black.withAlphaComponent(0.3)
        container.layer.cornerRadius = 20
        
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.color = .white
        
        addSubview(container)
        container.addSubview(indicator)
        container.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.center.equalToSuperview()
        }
        indicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}
