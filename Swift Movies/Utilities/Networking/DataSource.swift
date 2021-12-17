import Foundation
import Combine

class DataSource {
    private var subscribers = Set<AnyCancellable>()
    
    func request(_ request: URLRequest) -> AnyPublisher<Any, Errors> {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        let session = URLSession(configuration: configuration)
        
        return Future<Any, Errors> { [weak self] promise in
            guard let self = self else { return }
            
            session
                .dataTaskPublisher(for: request)
                .sink { completion in
                    switch completion {
                    case .failure:
                        promise(.failure(Errors.unableToComplete))
                    case .finished:
                        break
                    }
                } receiveValue: { data, response in
                    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                        promise(.failure(Errors.invalidResponse))
                        return
                    }
                    
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            promise(.failure(Errors.unableToCast))
                            return
                        }

                        promise(.success(json))
                    } catch {
                        promise(.failure(Errors.invalidJSON))
                    }
                }
                .store(in: &self.subscribers)
            
        }
        .eraseToAnyPublisher()
    }
}
