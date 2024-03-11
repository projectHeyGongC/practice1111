import Foundation
import AVFoundation

class SoundRecorder: NSObject {
    private let audioEngine = AVAudioEngine()
    private var audioBuffer: [Float] = []
    
    var onRecordingProcessed: ((Double) -> Void)?
    
    func startRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Configure the audio session for recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
            guard let self = self else { return }
            
            // Convert the audio buffer to an array of Float values
            let bufferPointer = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
            self.audioBuffer.append(contentsOf: Array(bufferPointer))
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error)")
            return
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        processRecordingData()
        audioBuffer.removeAll()
    }
    
    private func processRecordingData() {
        //let processor = PCMDataProcessor()
        let topAvg = PCMDataProcessor.calculateAverageOfTopTenPercent(from: audioBuffer)
        DispatchQueue.main.async {
            self.onRecordingProcessed?(topAvg)
        }
    }
}
