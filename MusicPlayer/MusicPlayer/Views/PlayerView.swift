import SwiftUI

struct PlayerView: View {
    
    // state and model objects
    @StateObject var vm = ViewModel()
    @State private var showFiles = false
    @State private var showFullPlayer = false
    @Namespace private var playerAnimation
    


    var frameImage: CGFloat {      // dynamic frame size for the player based on its state
        showFullPlayer ? 320 : 50
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                
                // MARK: - Background
                BackgroundView()

                VStack {

                   // list of songs with delete play
                    List {
                        ForEach(vm.songs) { song in
                            SongCell(song: song, durationFormated: vm.durationFormatted)
                                .onTapGesture {
                                    vm.playAudio(song: song)
                                }
                        }
                        .onDelete(perform: vm.delete)
                    }
                    .listStyle(.plain)
                    
                    Spacer()
                    
                    // mini or full player view
                    if vm.currentSong != nil {

                        Player()
                        .frame(height: showFullPlayer ? SizeConstant.fullPlayer : SizeConstant.miniPlayer)
                        .onTapGesture {
                            withAnimation(.spring) {
                                self.showFullPlayer.toggle()
                            }
                        }
                    }
                }
            }
            // MARK: - Navigation Bar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFiles.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
            
            // MARK: File's Sheet
            .sheet(isPresented: $showFiles, content: {
                ImportFileManager(songs: $vm.songs)
            })
        }
    }
    
    // MARK: - Methods
    private func Player() -> some View {
        VStack {
            
            /// Mini Player
            HStack {
                
                /// Cover
                SongImageView(imageData: vm.currentSong?.coverImage, size: frameImage)
                
                if !showFullPlayer {
                    
                    /// Description
                    VStack(alignment: .leading) {
                        SongDescription()
                        
                    }
                    .matchedGeometryEffect(id: "Description", in: playerAnimation)
                    
                    Spacer()
                    
                    CustomButton(image: vm.isPlaying ? "pause.fill" : "play.fill", size: .title) {
                        vm.playPause()
                    }
                }
            }
            .padding()
            .background(showFullPlayer ? .clear : .black.opacity(0.3))
            .cornerRadius(10)
            .padding()
            
            /// Full Player
            if showFullPlayer {
                
                /// Description
                VStack {
                    SongDescription()
                }
                .matchedGeometryEffect(id: "Description", in: playerAnimation)
                .padding(.top)
                
                VStack {
                    /// Duration
                    HStack {
                        Text("\(vm.durationFormatted(duration: vm.currentTime))")
                        Spacer()
                        Text("\(vm.durationFormatted(duration: vm.totalTime))")
                    }
                    .durationFont()
                    .padding()
                    
                    /// Slider
                    Slider(value: $vm.currentTime, in: 0...vm.totalTime) { editing in
                        
                        if !editing {
                            vm.seekAudio(time: vm.currentTime)
                        }
                    }
                    .offset(y: -18)
                    .accentColor(.white)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            vm.updateProgress()
                        }
                    }
                    
                    HStack(spacing: 40) {
                        CustomButton(image: "backward.end.fill", size: .title2) {
                            vm.backward()
                        }
                        CustomButton(image: vm.isPlaying ? "pause.circle.fill" : "play.circle.fill", size: .largeTitle) {
                            vm.playPause()
                        }
                        CustomButton(image: "forward.end.fill", size: .title2) {
                            vm.forward()
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    private func CustomButton(image: String, size: Font, action: @escaping () -> () ) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: image)
                .foregroundStyle(.white)
                .font(size)
        }
    }
    
    @ViewBuilder
    private func SongDescription() -> some View {
        if let currentSong = vm.currentSong {
            Text(currentSong.name)
                .nameFont()
            Text(currentSong.artist ?? "Unknow Artist")
                .artistFont()
        }
    }
}

#Preview {
    PlayerView()
}
