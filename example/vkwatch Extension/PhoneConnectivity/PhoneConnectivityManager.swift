//
//  PhoneConnectivityManager.swift
//  vkwatch Extension
//
//  Created by Дмитрий Червяков on 31.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

import Foundation
import WatchConnectivity

final class PhoneConnectivityManager: NSObject, WCSessionDelegate {

    private var session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }

    private func isReachable() -> Bool {
        return session.isReachable
    }

    func sendMessage() {
        /**
         *  The iOS device is within range, so communication can occur and the WatchKit extension is running in the
         *  foreground, or is running with a high priority in the background (for example, during a workout session
         *  or when a complication is loading its initial timeline data).
         */
        if isReachable() {
            session.sendMessage(["request" : "version"], replyHandler: { (response) in
                print(response)
            }, errorHandler: { (error) in
                print("Error sending message: %@", error)
            })
        } else {
            print("iPhone is not reachable!!")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
}
