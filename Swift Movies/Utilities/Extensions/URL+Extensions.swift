import Foundation

extension URL {
    func appending(_ queryItems: [URLQueryItem]? = nil) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + (queryItems ?? [])
        guard let url = urlComponents.url else { return self }
        return url
    }
}
