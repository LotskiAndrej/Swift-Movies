import Foundation

enum APIRouter {
    case movies(params: [URLQueryItem]?)
    case search(params: [URLQueryItem])
    
    private var method: String {
        switch self {
        case .movies, .search:
            return "GET"
        }
    }
    
    private var path: String {
        switch self {
        case .movies:
            return "/3/movie/popular"
        case .search:
            return "/3/search/movie"
        }
    }
    
    private var parameters: [URLQueryItem]? {
        switch self {
        case .movies(let params):
            return params
        case .search(let params):
            return params
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: Constants.Network.moviesURL) else {
            throw Errors.invalidURL
        }
        
        urlComponents.path = path
        urlComponents.queryItems = [URLQueryItem(name: "api_key",
                                                 value: Constants.Network.apiKey)]
        
        guard var url = urlComponents.url else {
            throw Errors.invalidURL
        }
        url = url.appending(parameters)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        return urlRequest
    }
}

