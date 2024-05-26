import Foundation
import AVFAudio

class ViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    // Properties
    // published for UI binding
    @Published var songs: [SongModel] = []
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentIndex: Int?
    @Published var currentTime: TimeInterval = 0.0
    @Published var totalTime: TimeInterval = 0.0
    
  // computed property for current song
    var currentSong: SongModel? {
        guard let currentIndex = currentIndex, songs.indices.contains(currentIndex) else {
            return nil
        }
        return songs[currentIndex]
    }
    
  // play audio from a specific song
    func playAudio(song: SongModel) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: song.data)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
            isPlaying = true
            totalTime = audioPlayer?.duration ?? 0.0
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                currentIndex = index
            }
        } catch {
            print("Error in audio playback: \(error.localizedDescription)")
        }
    }
    
   // toggle play or pause
    func playPause() {
        if isPlaying {
            self.audioPlayer?.pause()
        } else {
            self.audioPlayer?.play()
        }
        isPlaying.toggle()
    }
  // skip to the next
    func forward() {
        guard let currentIndex = currentIndex else { return }
        let nextIndex = currentIndex + 1 < songs.count ? currentIndex + 1 : 0
        playAudio(song: songs[nextIndex])
    }
   // return to  previous
    func backward() {
        guard let currentIndex = currentIndex else { return }
        let previousIndex = currentIndex > 0 ? currentIndex - 1 : songs.count - 1
        playAudio(song: songs[previousIndex])
    }
        // stop audio playback/
    func stopAudio() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        isPlaying = false
    }
      // seek to a specific time in the audio
    func seekAudio(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }

    func updateProgress() { // update playback progress
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
    }
    
      // format audio duration for display
    func durationFormatted(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }

  // handle audio playback completion
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            forward()
        }
    }

    func delete(offsets: IndexSet) {   // delete  song from list
        if let first = offsets.first {
            stopAudio()
            songs.remove(at: first)
        }
    }
}
