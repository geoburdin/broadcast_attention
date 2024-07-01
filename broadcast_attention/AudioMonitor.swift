import AVFoundation
import SwiftUI

class AudioMonitor: NSObject, ObservableObject {
    private var audioEngine: AVAudioEngine
    private var inputNode: AVAudioInputNode
    public var player: AVPlayer?

    @Published var isLoud: Bool = false

    init(videoURL: URL) {
        self.audioEngine = AVAudioEngine()
        self.inputNode = audioEngine.inputNode
        self.player = AVPlayer(url: videoURL)
        
        super.init()
        checkMicrophonePermission()
    }

    private func checkMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            setupAudioEngine()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    self.setupAudioEngine()
                } else {
                    print("Microphone access denied")
                }
            }
        case .denied, .restricted:
            print("Microphone access denied")
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }

    private func setupAudioEngine() {
        let inputFormat = inputNode.inputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
            self.analyzeAudio(buffer: buffer)
        }

        do {
            try audioEngine.start()
            print("Audio engine started")
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    private func analyzeAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else {
            print("Failed to get channel data")
            return
        }

        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        let rms = sqrt(channelDataArray.reduce(0) { $0 + $1 * $1 } / Float(buffer.frameLength))

        print("RMS: \(rms)")

        DispatchQueue.main.async {
            let previousIsLoud = self.isLoud
            self.isLoud = rms > 0.1 // Adjust threshold as needed
            if self.isLoud != previousIsLoud {
                print("Audio level crossed threshold. isLoud is now \(self.isLoud)")
            }
        }
    }
}
