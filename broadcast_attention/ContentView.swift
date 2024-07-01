import SwiftUI
import AVKit

struct ContentView: View {
    @ObservedObject var audioMonitor: AudioMonitor

    init() {
        let videoURL = URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!
        audioMonitor = AudioMonitor(videoURL: videoURL)
    }

    var body: some View {
        VStack {
            VideoPlayerView(player: audioMonitor.player!)
                .frame(width: audioMonitor.isLoud ? 600 : 300, height: audioMonitor.isLoud ? 400 : 200)
                .background(Color.black)
                .padding()

            Spacer()
        }
        .onAppear {
            audioMonitor.player?.play()
        }
    }
}
