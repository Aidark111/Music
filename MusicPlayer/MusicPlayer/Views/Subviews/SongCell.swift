import SwiftUI

struct SongCell: View {
    
    // MARK: - Properties
    let song: SongModel
    let durationFormated: (TimeInterval) -> String
    
    // MARK: - Body
    var body: some View {
        HStack {
            /// Cover
            SongImageView(imageData: song.coverImage, size: 60)
            
            /// Descroption
            VStack(alignment: .leading) {
                Text(song.name)
                    .nameFont()
                Text(song.artist ?? "Unknow Artist")
                    .artistFont()
            }
            
            Spacer()
            
            /// Duration
            if let duration = song.duration {
                Text(durationFormated(duration))
                    .artistFont()
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}


#Preview {
    PlayerView()
}
