import UIKit
import RealmSwift

class FavoritesListViewController: UIViewController {
    private var favoriteMovies = [RealmMovie]()
    private let tableView = UITableView()
    private let scrollDivider = UIView()
    private let header = UIView()
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
    }
    
    //MARK: - Private methods
    
    private func fetchFavorites() {
        DispatchQueue.main.async {
            self.favoriteMovies = self.realm.objects(RealmMovie.self).compactMap { $0 }
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Views
    
    private func setupMainView() {
        setupHeader()
        
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(FavoritesListTableViewCell.self,
                           forCellReuseIdentifier: Constants.MovieList.tableViewCellID)
        
        scrollDivider.backgroundColor = .systemGray
        scrollDivider.isHidden = true
        
        view.addSubview(scrollDivider)
        view.addSubview(tableView)
        scrollDivider.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(scrollDivider.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupHeader() {
        navigationController?.isNavigationBarHidden = true
        let headerLabel = UILabel()
        headerLabel.text = "Swift Movies"
        headerLabel.font = .boldSystemFont(ofSize: 32)
        headerLabel.textColor = .black
        headerLabel.textAlignment = .center
        
        view.addSubview(header)
        header.addSubview(headerLabel)
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        headerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview().inset(16)
        }
    }
}

//MARK: - TableView delegate and datasource methods

extension FavoritesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.MovieList.tableViewCellID,
                                                 for: indexPath) as! FavoritesListTableViewCell
        
        let movie = favoriteMovies[indexPath.row]
        cell.populate(posterURL: movie.posterImageUrlPath, title: movie.title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = Movie(with: favoriteMovies[indexPath.row])
        let vc = MovieDetailsViewController(movie: movie)
        vc.favoritesCallback = { [weak self] in
            self?.fetchFavorites()
        }
        navigationController?.present(vc, animated: true)
    }
}

//MARK: - ScrollView delegate methods

extension FavoritesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDivider.isHidden = scrollView.contentOffset.y > 10 ? false : true
    }
}
