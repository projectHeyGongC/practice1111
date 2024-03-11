import SwiftUI
import Combine
import AVFoundation

class SoundRecorderViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var soundData: [Double] = [] // This will hold processed data like averages
    private let soundRecorder = SoundRecorder()
    private var recordingTimer: Timer?
    private var restTimer: Timer?
    
    init() {
        soundRecorder.onRecordingProcessed = { [weak self] averageTopTenPercent in
            DispatchQueue.main.async {
                print("Processed Value: \(averageTopTenPercent)") // Diagnostic log
                self?.soundData.append(averageTopTenPercent)
                self?.checkSoundDataAndUpdateUI()
            }
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecordingCycle()
        } else {
            startRecordingCycle()
        }
        isRecording.toggle()
    }
    
    private func startRecordingCycle() {
        startRecording()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
            self?.startRecording()
        }
    }
    
    private func startRecording() {
        soundRecorder.startRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.soundRecorder.stopRecording()
        }
    }
    
    private func stopRecordingCycle() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        soundRecorder.stopRecording()
    }
    
    private func checkSoundDataAndUpdateUI() {
        // Update your UI or perform actions based on sound data exceeding thresholds.
        // For example, changing colors or triggering alerts.
    }
}

struct RecordingScreen: View {
    @StateObject private var viewModel = SoundRecorderViewModel()
    
    var body: some View {
        VStack {
            Text("Sound Data: \(viewModel.soundData.map { String($0) }.joined(separator: ", "))")
                .padding()
            
            Button(action: viewModel.toggleRecording) {
                Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                    .foregroundColor(.white)
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(colorForSoundData(viewModel.soundData.last))
    }
    
    private func colorForSoundData(_ soundValue: Double?) -> Color {
        guard let soundValue = soundValue, soundValue > 0.003 else {
            return Color(.systemBackground) // Use default system background color
        }
        return Color.blue // Use blue color for background if the condition is met
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingScreen()
    }
}
