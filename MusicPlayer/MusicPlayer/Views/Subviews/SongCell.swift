import SwiftUI

struct SongCell: View {
    
  // properties for song data and formatting
    let song: SongModel
    let durationFormated: (TimeInterval) -> String
    
    
    var body: some View {
        HStack {
            // сover
            SongImageView(imageData: song.coverImage, size: 60)
            
            // Descroption
            VStack(alignment: .leading) {
                Text(song.name)
                    .nameFont()
                Text(song.artist ?? "Unknow Artist")
                    .artistFont()
            }
            
            Spacer()
            
            // Duration
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
