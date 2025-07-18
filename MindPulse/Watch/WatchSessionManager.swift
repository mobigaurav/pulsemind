//
//  WatchSessionManager.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    //@ObservedObject var viewModel: HealthKitViewModel
    static let shared = WatchSessionManager()
    private override init() { super.init() }
    var healthDataHandler: ((_ hr: Double, _ hrv: Double) -> Void)?
    
    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func sendMoodToiPhone(_ mood: String) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["mood": mood], replyHandler: nil)
        }
    }

    // MARK: WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) { }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let mood = message["mood"] as? String {
            print("Received mood from watch: \(mood)")
            // Save mood locally, e.g., Core Data JournalEntry
            JournalManager.shared.saveMoodOnlyEntry(mood)
        }
        
        if let hr = message["heartRate"] as? Double,
                  let hrv = message["hrv"] as? Double {
                   print("Received HR: \(hr), HRV: \(hrv) from watch")

                   // Forward to view model if registered
                   self.healthDataHandler?(hr, hrv)
               }
    }
}

extension Notification.Name {
    static let watchDataUpdated = Notification.Name("watchDataUpdated")
}

