//
//  WatchSessionManager.swift
//  MindPulse Watch Watch App
//
//  Created by Gaurav Kumar on 7/18/25.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    

    
    private override init() {
        super.init()
        activate()
    }

    private func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func sendHealthData(heartRate: Double, hrv: Double, streesScore:Int) {
        let data: [String: Any] = [
            "heartRate": heartRate,
            "hrv": hrv,
            "streesScore": streesScore
        ]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(data, replyHandler: nil, errorHandler: { error in
                print("Error sending health data: \(error)")
            })
        } else {
            WCSession.default.transferUserInfo(data)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activated: \(activationState.rawValue)")
    }
}

