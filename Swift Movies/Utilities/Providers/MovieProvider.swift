import Foundation
import Combine

class MovieProvider {
    private var subscribers = Set<AnyCancellable>()
    private let dataSource = DataSource()
    
    // Subjects
    let movieListDataSubject = PassthroughSubject<[Movie], Never>()
    let errorSubject = PassthroughSubject<Errors, Never>()
    
    /// Fetches json data from provided route, throws error if failure occurs
    func fetchData(route: APIRouter) {
        do {
            let request = try route.asURLRequest()
            
            dataSource
                .request(request)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorSubject.send(error)
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] json in
                    print(json)
                    self?.parseData(with: json)
                }
                .store(in: &subscribers)
        } catch {
            errorSubject.send(Errors.unableToCreateRequest)
        }
    }
    
    /// Parse json data into an array of Movie objects
    private func parseData(with json: Any) {
        var movies = [Movie]()
        if let json = json as? [String: Any],
           let results = json["results"] as? [[String: Any]] {
            
            for movieData in results {
                if let movie = Movie(with: movieData) {
                    movies.append(movie)
                }
            }
            
            movies.sort { $0.popularity > $1.popularity }
            movieListDataSubject.send(movies)
        }
    }
}
