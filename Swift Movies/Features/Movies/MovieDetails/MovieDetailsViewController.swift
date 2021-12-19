import UIKit
import Kingfisher
import RealmSwift

class MovieDetailsViewController: UIViewController {
    private let movie: Movie
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let favoriteButton = UIView()
    private let favoriteButtonImageView: UIImageView
    private let closeButtonContainer = UIView()
    private let titleLabel = UILabel()
    private var starView: StarRatingView
    private let releaseDateContainer = UIView()
    private let descriptionLabel = UILabel()
    private let realm = try! Realm()
    private let realmMovie: RealmMovie
    var favoritesCallback: (() -> Void)?
    
    init(movie: Movie) {
        self.movie = movie
        starView = StarRatingView(size: 38, rating: movie.rating)
        favoriteButtonImageView = UIImageView(image: UIImage(systemName: Constants.Images.starFill))
        realmMovie = RealmMovie(with: movie)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - Selectors
    
    @objc private func closeView() {
        dismiss(animated: true)
    }
    
    //MARK: - Views
    
    private func setupView() {
        view.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        
        setupImage()
        setupTitle()
        setupReleaseDate()
        setupDescription()
        setupConstraints()
    }
    
    private func setupImage() {
        imageView.setImage(from: movie.posterImageUrlPath)
        imageView.setForegroundGradient(colors: [.black.withAlphaComponent(0.6), .clear],
                                        frame: CGRect(x: 0, y: 0,
                                                      width: view.bounds.size.width,
                                                      height: 80))
        
        let closeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        closeButtonContainer.isUserInteractionEnabled = true
        closeButtonContainer.addGestureRecognizer(closeButtonTapGesture)
        let closeButton = UIImageView(image: UIImage(systemName: Constants.Images.arrowtriangleDownFill))
        closeButton.tintColor = .white
        
        closeButtonContainer.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(16)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleFavorites))
        favoriteButton.addGestureRecognizer(tap)
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        favoriteButton.backgroundColor = .white
        favoriteButton.layer.cornerRadius = 25
        favoriteButton.layer.borderWidth = 0.5
        favoriteButton.layer.borderColor = UIColor.black.cgColor
        
        if realm.object(ofType: RealmMovie.self, forPrimaryKey: movie.id) != nil {
            favoriteButtonImageView.tintColor = .black
        } else {
            favoriteButtonImageView.tintColor = .systemGray3
        }
        
        favoriteButton.addSubview(favoriteButtonImageView)
        favoriteButtonImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(25)
        }
    }
    
    private func setupTitle() {
        titleLabel.text = movie.title
        titleLabel.font = .systemFont(ofSize: 34, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
    }
    
    private func setupReleaseDate() {
        releaseDateContainer.backgroundColor = .systemGray5
        releaseDateContainer.layer.cornerRadius = 10
        
        let releaseDateLabel = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
        releaseDateLabel.font = .systemFont(ofSize: 16)
        releaseDateLabel.textColor = .systemGray
        releaseDateLabel.textAlignment = .left
        
        releaseDateContainer.addSubview(releaseDateLabel)
        releaseDateLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.width.equalToSuperview().inset(12)
        }
    }
    
    private func setupDescription() {
        descriptionLabel.text = movie.desc
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textColor = .black
        descriptionLabel.textAlignment = .left
    }
    
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(closeButtonContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(starView)
        contentView.addSubview(releaseDateContainer)
        contentView.addSubview(descriptionLabel)
        scrollView.snp.makeConstraints { $0.edges.width.equalToSuperview() }
        contentView.snp.makeConstraints { $0.edges.width.equalToSuperview() }
        imageView.snp.makeConstraints { make in
            make.top.leading.width.equalToSuperview()
            make.height.equalTo(view.bounds.size.width * 1.6)
        }
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView.snp.bottom)
            make.trailing.equalToSuperview().inset(16)
            make.height.width.equalTo(50)
        }
        closeButtonContainer.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.height.equalTo(80)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(favoriteButton.snp.leading)
        }
        starView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(16)
        }
        releaseDateContainer.snp.makeConstraints { make in
            make.top.equalTo(starView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(16)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(releaseDateContainer.snp.bottom).offset(16)
            make.leading.width.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    //MARK: - Selectors
    
    @objc private func toggleFavorites() {
        favoriteButton.isUserInteractionEnabled = false
        
        if let object = realm.object(ofType: RealmMovie.self, forPrimaryKey: realmMovie.id) {
            try! realm.write {
                realm.delete(object)
            }
            favoriteButtonImageView.tintColor = .systemGray3
        } else {
            try! realm.write {
                realm.add(realmMovie, update: .modified)
            }
            favoriteButtonImageView.tintColor = .black
        }
        
        favoriteButton.isUserInteractionEnabled = true
        favoritesCallback?()
    }
}
