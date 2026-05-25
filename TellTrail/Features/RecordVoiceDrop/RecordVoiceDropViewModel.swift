import AVFoundation
import Combine
import Foundation

final class RecordVoiceDropViewModel: NSObject, ObservableObject {
    @Published var title = ""
    @Published var caption = ""
    @Published var locationName = "MG Road Metro, Bengaluru"
    @Published var selectedRange = "100m"
    @Published var selectedVisibility = "Public"
    @Published private(set) var isRecording = false
    @Published private(set) var hasRecording = false
    @Published private(set) var isPreviewing = false
    @Published private(set) var elapsedSeconds = 0
    @Published private(set) var photoAttachmentName: String?
    @Published private(set) var videoAttachmentName: String?
    @Published private(set) var photoURL: URL?
    @Published private(set) var saveMessage: String?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSaved = false

    let ranges = ["25m", "50m", "100m", "500m", "Global"]
    let visibilityOptions = ["Public", "Followers", "Private"]

    private let dataStore: TrailDataStore?
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var recordingURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("telltrail-voice-drop.m4a")
    }

    init(dataStore: TrailDataStore? = nil) {
        self.dataStore = dataStore
        super.init()
    }

    var durationText: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var recordingProgress: Double {
        min(Double(elapsedSeconds) / 60.0, 1.0)
    }

    var canSave: Bool {
        !isSaved
            && hasRecording
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    deinit {
        timer?.invalidate()
        audioRecorder?.stop()
        audioPlayer?.stop()
    }

    func toggleRecording() {
        guard !isSaved else { return }
        isRecording ? stopRecording() : startRecording()
    }

    func previewRecording() {
        guard !isSaved, hasRecording else { return }

        if isPreviewing {
            audioPlayer?.stop()
            isPreviewing = false
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPreviewing = true
        } catch {
            errorMessage = "Could not play this recording."
        }
    }

    func retakeRecording() {
        guard !isSaved else { return }
        audioPlayer?.stop()
        audioRecorder?.stop()
        timer?.invalidate()
        isRecording = false
        isPreviewing = false
        hasRecording = false
        elapsedSeconds = 0
        saveMessage = nil
        try? FileManager.default.removeItem(at: recordingURL)
    }

    func attachPhotoData(_ data: Data?) {
        guard !isSaved, let data, !data.isEmpty else { return }

        do {
            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("telltrail-photo-\(UUID().uuidString).jpg")
            try data.write(to: destinationURL, options: Data.WritingOptions.atomic)
            photoURL = destinationURL
            photoAttachmentName = "Photo attached"
            errorMessage = nil
        } catch {
            errorMessage = "Could not attach the selected photo."
        }
    }

    func attachVideo() {
        guard !isSaved else { return }
        videoAttachmentName = "Video attached"
        errorMessage = nil
    }

    func removePhoto() {
        guard !isSaved else { return }
        if let photoURL {
            try? FileManager.default.removeItem(at: photoURL)
        }
        photoURL = nil
        photoAttachmentName = nil
    }

    func removeVideo() {
        guard !isSaved else { return }
        videoAttachmentName = nil
    }

    func deleteDraft() {
        guard !isSaved else { return }
        title = ""
        caption = ""
        locationName = "MG Road Metro, Bengaluru"
        selectedRange = "100m"
        selectedVisibility = "Public"
        if let photoURL {
            try? FileManager.default.removeItem(at: photoURL)
        }
        photoURL = nil
        photoAttachmentName = nil
        videoAttachmentName = nil
        errorMessage = nil
        saveMessage = nil
        retakeRecording()
    }

    func saveDrop() {
        guard canSave else {
            errorMessage = "Add a title, location, and recording before saving."
            return
        }

        dataStore?.addVoiceDrop(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
            locationName: locationName.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: durationText,
            range: selectedRange,
            audioURL: persistedRecordingURL(),
            imageURL: photoURL
        )
        saveMessage = nil
        errorMessage = nil
        lockFormAfterSave()
    }

    private func persistedRecordingURL() -> URL? {
        guard FileManager.default.fileExists(atPath: recordingURL.path) else { return nil }

        let destinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("telltrail-\(UUID().uuidString).m4a")
        do {
            try FileManager.default.copyItem(at: recordingURL, to: destinationURL)
            return destinationURL
        } catch {
            return recordingURL
        }
    }

    private func lockFormAfterSave() {
        audioPlayer?.stop()
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
        isPreviewing = false
        isSaved = true
    }

    private func startRecording() {
        saveMessage = nil
        errorMessage = nil
        audioPlayer?.stop()
        isPreviewing = false

        AVAudioApplication.requestRecordPermission { [weak self] isAllowed in
            DispatchQueue.main.async {
                guard let self else { return }
                guard isAllowed else {
                    self.errorMessage = "Microphone permission is needed to record."
                    return
                }

                self.configureRecorder()
            }
        }
    }

    private func configureRecorder() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try session.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
            hasRecording = false
            elapsedSeconds = 0
            startTimer()
        } catch {
            errorMessage = "Could not start recording."
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
        hasRecording = elapsedSeconds > 0
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            elapsedSeconds += 1
        }
    }
}

extension RecordVoiceDropViewModel: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        timer?.invalidate()
        isRecording = false
        errorMessage = "Recording failed. Please try again."
    }
}

extension RecordVoiceDropViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPreviewing = false
    }
}
