import Foundation
import Combine

enum MovieListState {
    case `default`
    case error
}

class MovieListViewModel: ObservableObject {
    private let provider = MovieProvider()
    private var subscribers = Set<AnyCancellable>()
    private let perPage = 20
    private var isSearching = false
    
    // Publishers
    @Published var movies = [Movie]()
    @Published var state = MovieListState.default
    @Published var shouldShowErrorPopoup = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var currentPage = 1 {
        didSet {
            fetchMovies()
        }
    }
    
    init() {
        subscribeAndFetchMovies()
    }
    
    /// Constructs URL from movie image path
    func getImageUrl(for movie: Movie) -> URL? {
        URL(string: Constants.Network.imageURL + movie.posterImageUrlPath)
    }
    
    /// Checks if the movie is the last one in the list,
    /// if so, increments the current page index
    func checkIfLast(movie: Movie) {
        if movies.last == movie {
            currentPage += 1
        }
    }
    
    /// Fetches movies based on the text entered in the search field
    func searchMovies(text: String) {
        // Checks if the user cleared the search field,
        // if so, resets the movies list and current page index,
        // and fetches most popular movies
        if text.isEmpty {
            currentPage = 1
            movies = []
            fetchMovies()
            return
        }
        
        isLoading = true
        isSearching = true
        let params = [URLQueryItem(name: "query", value: text)]
        print(text)
        provider.fetchData(route: .search(params: params))
    }
    
    /// Fetches movies with current page index
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
                guard let self = self else { return }
                
                self.isLoading = false
                
                if self.isSearching {
                    self.isSearching = false
                    self.movies = movies
                } else {
                    self.movies.append(contentsOf: movies)
                }
            }
            .store(in: &subscribers)
        
        provider
            .errorSubject
            .sink { [weak self] error in
                guard let self = self else { return }
                
                self.errorMessage = error.rawValue
                
                if self.movies.count > self.perPage {
                    self.shouldShowErrorPopoup = true
                } else {
                    self.state = .error
                }
            }
            .store(in: &subscribers)
        
        fetchMovies()
    }
}
