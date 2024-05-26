import Foundation

struct SongModel: Identifiable, Hashable {
    var id = UUID()  // unique id for each song
    var name: String
    var data: Data  // audio data
    var artist: String?
    var coverImage: Data?
    var duration: TimeInterval? // optional duration of the song
}
