import Foundation

enum Errors: String, Error {
    case invalidURL = "Invalid URL"
    case invalidData = "Invalid Data"
    case invalidResponse = "Invalid Response"
    case invalidJSON = "Invalid JSON"
    
    case unableToComplete = "Unable to complete"
    case unableToAppend = "Unable to construct queries"
    case unableToCast = "Unable to cast JSON"
    case unableToCreateRequest = "Unable to create request"
    
    case emptyList = "There were no movies matching your search, please try something else"
    case emptyFavoritesList = "There are no movies in your favorites"
}
