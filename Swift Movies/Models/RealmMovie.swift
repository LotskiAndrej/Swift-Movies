import Foundation
import RealmSwift

class RealmMovie: Object, Identifiable {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var releaseDate: Date = Date()
    @objc dynamic var rating: Double = 0.0
    @objc dynamic var popularity: Double = 0.0
    @objc dynamic var posterImageUrlPath: String = ""
    @objc dynamic var language: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(with movie: Movie) {
        self.init()
        
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
