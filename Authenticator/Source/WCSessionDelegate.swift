//
//  WCSessionDelegate.swift
//  Authenticator
//
//  Created by martin on 26/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation
import WatchConnectivity

// MARK: - WatchConnectivity

@available(iOS 9.0, *)
extension TokenStore : WCSessionDelegate {

    func activateWCSession() {
        guard WCSession.isSupported() else {
            return
        }
        let session = WCSession.defaultSession()
        session.delegate = self // before activate
        session.activateSession()
    }

    // We're not interested in the life cycle of the
    // watch connection. Hence, these methods are just
    // empty placeholders to fulfill the protocol.
    @available(iOS 9.3, *)
    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
    }
    func sessionDidBecomeInactive(session: WCSession) {
    }
    func sessionDidDeactivate(session: WCSession) {
    }
    
    private var session:WCSession? {
        // is the framework available at all?
        guard WCSession.isSupported() else {
            return nil
        }
        let session = WCSession.defaultSession()
        if #available(iOS 9.3, *) {
            // can we use it to communicate?
            guard session.activationState == .Activated else {
                return nil
            }
        }
        return session
    }
    
    func sendTokens() throws {
        // we transport the tokens as [NSURL, NSURL, NSURL, ...]
        let urls = try persistentTokens.map() { try $0.token.toURL() }
        // converted to NSData
        let data = NSKeyedArchiver.archivedDataWithRootObject(urls)
        // and ship it
        simpleSendData(kTokensMessage, data: data)
    }

    // validation free simple send and forget
    func simpleSendData(name:String, data:NSData) {
        session?.sendMessage(["name":name, "data":data], replyHandler: nil, errorHandler: {
            // not much of a problem, because we don't really care
            print("sendMessage failed \($0)")
        })
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let name = message["name"] as! String;
        switch name {
        case kRequestTokensMessage:
            // watch wants tokens
            do {
                try sendTokens()
            } catch {
                print("sendTokens from request failed \(error)")
            }
        default:
            print("Received message with unknown name ", name)
        }
    }
    
}
