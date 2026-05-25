import AVFAudio
import AVFoundation
import CoreLocation
import Foundation
import UserNotifications

@MainActor
final class AppPermissionManager: NSObject, CLLocationManagerDelegate {
    static let shared = AppPermissionManager()

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<Void, Never>?
    private var hasRequestedInitialPermissions = false

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestInitialPermissions() async {
        guard !hasRequestedInitialPermissions else { return }
        hasRequestedInitialPermissions = true

        await requestLocationPermission()
        await requestCameraPermission()
        await requestMicrophonePermission()
        await requestNotificationPermission()
    }

    private func requestLocationPermission() async {
        guard hasUsageDescription("NSLocationWhenInUseUsageDescription") else { return }

        let status = locationManager.authorizationStatus
        guard status == .notDetermined else { return }

        await withCheckedContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func requestCameraPermission() async {
        guard hasUsageDescription("NSCameraUsageDescription") else { return }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined else { return }

        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { _ in
                continuation.resume()
            }
        }
    }

    private func requestMicrophonePermission() async {
        guard hasUsageDescription("NSMicrophoneUsageDescription") else { return }
        guard AVAudioApplication.shared.recordPermission == .undetermined else { return }

        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { _ in
                continuation.resume()
            }
        }
    }

    private func hasUsageDescription(_ key: String) -> Bool {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return false }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func requestNotificationPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }

        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            // The app can continue if notification permission is unavailable or denied.
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationContinuation?.resume()
        locationContinuation = nil
    }
}
