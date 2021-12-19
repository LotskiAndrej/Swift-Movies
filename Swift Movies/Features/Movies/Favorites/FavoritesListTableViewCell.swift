import UIKit

class FavoritesListTableViewCell: UITableViewCell {
    private let cellImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Populates cell with movie poster image url and title
    func populate(posterURL: String, title: String) {
        cellImageView.setImage(from: posterURL)
        titleLabel.text = title
    }
    
    private func setupCell() {
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.layer.cornerRadius = 10
        cellImageView.clipsToBounds = true
        
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        
        addSubview(cellImageView)
        addSubview(titleLabel)
        cellImageView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(50)
            make.height.equalTo(80)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(cellImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }
}
