import Foundation
import Combine

enum MovieListState {
    case `default`
    case error
}

class MovieListViewModel: ObservableObject {
    private let provider = MovieProvider()
    private var subscribers = Set<AnyCancellable>()
    private var queryText = ""
    private var currentPage = 1
    private(set) var errorMessage = ""
    
    // Publishers
    @Published var movies = [Movie]()
    @Published var state = MovieListState.default
    @Published var shouldShowErrorPopoup = false
    @Published var isLoading = false
    
    init() {
        subscribeAndFetchMovies()
    }
    
    //MARK: - Public methods
    
    /// Constructs URL from movie image path
    func getImageUrl(for movie: Movie) -> URL? {
        URL(string: Constants.Network.imageURL + movie.posterImageUrlPath)
    }
    
    /// Checks if the movie is the last one in the list,
    /// if so, increments the current page index
    func checkIfLast(movie: Movie) {
        if movies.last == movie {
            currentPage += 1
            if queryText.isEmpty {
                fetchMovies()
            } else {
                searchMovies(text: queryText)
            }
        }
    }
    
    func resetMovies() {
        // Resets the movies list and current page index,
        // and fetches most popular movies
        queryText = ""
        currentPage = 1
        movies = []
        fetchMovies()
    }
    
    func search(with text: String) {
        movies = []
        currentPage = 1
        searchMovies(text: text)
    }
    
    //MARK: - Private methods
    
    /// Fetches movies based on the text entered in the search field
    private func searchMovies(text: String) {
        queryText = text
        isLoading = true
        let params = [URLQueryItem(name: "query", value: queryText),
                      URLQueryItem(name: "page", value: String(currentPage))]
        provider.fetchData(route: .search(params: params))
    }
    
    /// Fetches most popular movies with current page index
    private func fetchMovies() {
        isLoading = true
        let params = [URLQueryItem(name: "page", value: String(currentPage))]
        provider.fetchData(route: .movies(params: params))
    }
    
    /// Subscribes to subjects to recieve values after
    /// network call finishes and fetches movies
    private func subscribeAndFetchMovies() {
        provider
            .movieListDataSubject
            .sink { [weak self] movies in
                self?.isLoading = false
                if !movies.isEmpty {
                    self?.movies.append(contentsOf: movies)
                }
            }
            .store(in: &subscribers)
        
        provider
            .errorSubject
            .sink { [weak self] error in
                guard let self = self else { return }
                
                self.errorMessage = error.rawValue
                
                // The number 20 is the number of movies per page
                if self.movies.count > 20 {
                    self.shouldShowErrorPopoup = true
                } else {
                    self.state = .error
                }
            }
            .store(in: &subscribers)
        
        fetchMovies()
    }
}
