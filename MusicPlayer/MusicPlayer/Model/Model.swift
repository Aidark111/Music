import Foundation

struct SongModel: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var data: Data
    var artist: String?
    var coverImage: Data?
    var duration: TimeInterval?
}
