import UIKit
import SnapKit
import Combine

class MovieListViewController: UIViewController {
    private let viewModel = MovieListViewModel()
    private var movies = [Movie]()
    private let indicator = FloatingIndicatorView()
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private let searchBar = UISearchBar()
    private let scrollToTopButton = UIView()
    private let scrollDivider = UIView()
    private var autosearchTimer: AutosearchTimer?
    private var subscribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainView()
        setupSubscribers()
    }
    
    //MARK: - Subscribers
    
    /// Subscribes to published properties of viewModel
    private func setupSubscribers() {
        viewModel
            .$state
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .error, .emptyList:
                    self.collectionView.setEmptyMessage(self.viewModel.errorMessage)
                default:
                    self.collectionView.restore()
                }
            }
            .store(in: &subscribers)
        
        viewModel
            .$movies
            .sink { [weak self] movies in
                self?.movies = movies
                self?.collectionView.reloadData()
            }
            .store(in: &subscribers)
        
        viewModel
            .$isLoading
            .sink { [weak self] isLoading in
                self?.indicator.isHidden = !isLoading
            }
            .store(in: &subscribers)
        
        viewModel
            .$shouldShowErrorPopoup
            .sink { [weak self] shouldShowErrorPopoup in
                if shouldShowErrorPopoup {
                    self?.showErrorPopup()
                }
            }
            .store(in: &subscribers)
    }
    
    //MARK: - Selectors
    
    @objc private func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

//MARK: - View setup

extension MovieListViewController {
    
    //MARK: - Header view
    
    private func setupHeader() {
        navigationController?.isNavigationBarHidden = true
        let header = UIView()
        let headerLabel = UILabel()
        headerLabel.text = "Swift Movies"
        headerLabel.font = .boldSystemFont(ofSize: 32)
        headerLabel.textColor = .black
        headerLabel.textAlignment = .center
        
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search..."
        
        view.addSubview(header)
        view.addSubview(searchBar)
        header.addSubview(headerLabel)
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        headerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    //MARK: - Main movie list view
    
    private func setupMainView() {
        setupHeader()
        
        view.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = true
        collectionView.register(MovieListCollectionCell.self,
                                forCellWithReuseIdentifier: Constants.MovieList.collectionCellID)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 20
        // Calculates width to equal half of parent view minus padding
        let cellWidth = (view.frame.width / 2) - 24
        // Calculates height to equal width plus text height
        let cellHeight = (cellWidth * 1.6) + 60
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.collectionViewLayout = layout
        
        scrollDivider.backgroundColor = .systemGray
        scrollDivider.isHidden = true
        
        view.addSubview(scrollDivider)
        view.addSubview(collectionView)
        view.addSubview(indicator)
        scrollDivider.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(scrollDivider.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
        indicator.snp.makeConstraints { $0.center.equalToSuperview() }
        
        setupFloatingScrollToTopButton()
    }
    
    //MARK: - Floating scroll to top button
    
    private func setupFloatingScrollToTopButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
        scrollToTopButton.addGestureRecognizer(tap)
        scrollToTopButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        scrollToTopButton.backgroundColor = .white.withAlphaComponent(0.95)
        scrollToTopButton.layer.cornerRadius = 30
        scrollToTopButton.layer.borderWidth = 0.5
        scrollToTopButton.layer.borderColor = UIColor.black.cgColor
        scrollToTopButton.layer.shadowRadius = 5
        scrollToTopButton.layer.shadowColor = UIColor.black.cgColor
        scrollToTopButton.layer.shadowOpacity = 0.4
        scrollToTopButton.layer.shouldRasterize = true
        scrollToTopButton.layer.rasterizationScale = UIScreen.main.scale
        scrollToTopButton.isHidden = true
        scrollToTopButton.layer.shadowPath = UIBezierPath(roundedRect: scrollToTopButton.bounds,
                                                          cornerRadius: 30).cgPath
        
        let imageView = UIImageView(image: UIImage(systemName: Constants.Images.arrowUp))
        imageView.tintColor = .black
        
        view.addSubview(scrollToTopButton)
        scrollToTopButton.addSubview(imageView)
        scrollToTopButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.width.equalTo(60)
        }
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(25)
        }
    }
    
    private func showErrorPopup() {
        let alert = UIAlertController(title: nil, message: viewModel.errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - CollectionView delegate and datasource nethods

extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        viewModel.checkIfLast(movie: movies[indexPath.row])
        
        if indexPath.row > 6 && scrollToTopButton.isHidden {
            self.scrollToTopButton.isHidden = false
        } else if indexPath.row < 6 && !scrollToTopButton.isHidden {
            self.scrollToTopButton.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.MovieList.collectionCellID,
                                                      for: indexPath) as! MovieListCollectionCell
        
        let movie = movies[indexPath.row]
        cell.populate(posterURL: movie.posterImageUrlPath, title: movie.title)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.present(MovieDetailsViewController(movie: movies[indexPath.row]),
                                      animated: true)
    }
}

//MARK: - SearchBar delegate methods

extension MovieListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.resetMovies()
        autosearchTimer?.cancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If user clears search bar, perform search instantly,
        // else delay for 0.8 seconds before searching
        if searchText.isEmpty {
            searchBar.showsCancelButton = false
            viewModel.resetMovies()
            autosearchTimer?.cancel()
        } else {
            searchBar.showsCancelButton = true
            autosearchTimer = AutosearchTimer(interval: 0.8) { [weak self] in
                self?.viewModel.search(with: searchText)
            }
            autosearchTimer?.activate()
        }
    }
}

//MARK: - ScrollView delegate methods

extension MovieListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDivider.isHidden = scrollView.contentOffset.y > 10 ? false : true
    }
}
