import Foundation

struct Movie: Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let releaseDate: Date
    let rating: Double
    let popularity: Double
    let posterImageUrlPath: String
    
    init?(with json: [String: Any]) {
        guard let id = json["id"] as? Int,
              let title = json["title"] as? String,
              let description = json["overview"] as? String,
              let releaseDateString = json["release_date"] as? String,
              let rating = json["vote_average"] as? Double,
              let popularity = json["popularity"] as? Double,
              let posterImageUrlPath = json["poster_path"] as? String
        else { return nil }
        
        self.id = id
        self.title = title
        self.description = description
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let releaseDate = formatter.date(from: releaseDateString) else {
            return nil
        }
        self.releaseDate = releaseDate
        
        self.rating = rating
        self.popularity = popularity
        self.posterImageUrlPath = posterImageUrlPath
    }
}
