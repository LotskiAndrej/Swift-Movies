import UIKit
import SnapKit
import Combine

class MovieListViewController: UIViewController {
    private let viewModel = MovieListViewModel()
    private var movies = [Movie]()
    private let header = UIView()
    private let indicator = FloatingIndicatorView()
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private let searchBar = UISearchBar()
    private var autosearchTimer: AutosearchTimer?
    private var subscribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscribers()
    }
    
    //MARK: - Subscribers
    
    /// Subscribes to published properties of viewModel
    private func setupSubscribers() {
        viewModel
            .$state
            .sink { [weak self] state in
                state == .default ?
                self?.setupSuccessView() :
                self?.setupErrorView()
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
}

//MARK: - View setup

extension MovieListViewController {
    private func setupHeader() {
        view.backgroundColor = .white
        let headerLabel = UILabel()
        headerLabel.text = "Swift Movies"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 32)
        headerLabel.textColor = .black
        headerLabel.textAlignment = .center
        
        header.addSubview(headerLabel)
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        headerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func setupSuccessView() {
        setupHeader()
        
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search..."
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieListCollectionCell.self,
                                forCellWithReuseIdentifier: Constants.MovieList.collectionCellID)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 20
        // Calculates width to equal half of parent view minus padding
        let cellWidth = (view.frame.width / 2) - 24
        // Calculates height to equal width plus text height
        let cellHeight = (cellWidth * (1 / (10 / 16))) + 60
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.collectionViewLayout = layout
        
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(indicator)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupErrorView() {
        setupHeader()
        
        let container = UIView()
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        imageView.tintColor = .black
        let errorMessageLabel = UILabel()
        errorMessageLabel.text = viewModel.errorMessage
        errorMessageLabel.font = UIFont.systemFont(ofSize: 20)
        errorMessageLabel.textColor = .black
        errorMessageLabel.textAlignment = .center
        
        container.addSubview(imageView)
        container.addSubview(errorMessageLabel)
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(80)
            make.centerX.equalToSuperview()
        }
        errorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.leading.trailing.centerX.equalToSuperview()
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
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // If user clears search bar, perform search instantly,
        // else delay for 0.8 seconds before searching
        if searchText.isEmpty {
            viewModel.resetMovies()
            searchBar.showsCancelButton = false
        } else {
            searchBar.showsCancelButton = true
            autosearchTimer = AutosearchTimer(interval: 0.8) { [weak self] in
                self?.viewModel.search(with: searchText)
            }
            autosearchTimer?.activate()
        }
    }
}
