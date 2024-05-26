import SwiftUI

@main
struct MusicPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 14.0, *) {
                PlayerView()   // main view of the app

            } else {
 
              Text("This app requires iOS 14.0 or newer.")
            }
        }
    }
}


