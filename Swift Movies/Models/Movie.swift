import Foundation

struct Movie: Identifiable, Equatable {
    let id: Int
    let title: String
    let desc: String
    let releaseDate: Date
    let rating: Double
    let popularity: Double
    let posterImageUrlPath: String
    let language: String
    
    init?(with json: [String: Any]) {
        guard let id = json["id"] as? Int,
              let title = json["title"] as? String,
              let desc = json["overview"] as? String,
              let releaseDateString = json["release_date"] as? String,
              let rating = json["vote_average"] as? Double,
              let popularity = json["popularity"] as? Double,
              let posterImageUrlPath = json["poster_path"] as? String,
              let language = json["original_language"] as? String,
              language == "en"
        else { return nil }
        
        self.id = id
        self.title = title
        self.desc = desc
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let releaseDate = formatter.date(from: releaseDateString) else {
            return nil
        }
        self.releaseDate = releaseDate
        
        self.rating = rating
        self.popularity = popularity
        self.posterImageUrlPath = posterImageUrlPath
        self.language = language
    }
    
    init(with movie: RealmMovie) {
        self.id = movie.id
        self.title = movie.title
        self.desc = movie.desc
        self.releaseDate = movie.releaseDate
        self.rating = movie.rating
        self.popularity = movie.popularity
        self.posterImageUrlPath = movie.posterImageUrlPath
        self.language = movie.language
    }
}
