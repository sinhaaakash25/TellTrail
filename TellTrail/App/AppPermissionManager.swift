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
        let status = locationManager.authorizationStatus
        guard status == .notDetermined else { return }

        await withCheckedContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func requestCameraPermission() async {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined else { return }

        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { _ in
                continuation.resume()
            }
        }
    }

    private func requestMicrophonePermission() async {
        guard AVAudioSession.sharedInstance().recordPermission == .undetermined else { return }

        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { _ in
                continuation.resume()
            }
        }
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
