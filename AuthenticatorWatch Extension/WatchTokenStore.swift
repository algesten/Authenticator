//
//  WatchTokenStore.swift
//  Authenticator
//
//  Created by martin on 23/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation
import OneTimePassword
import WatchConnectivity

private let kRequestTokensMessage = "OTPRequestTokensMessage"
private let kPersistentTokensMessage = "OTPPersistentTokensMessage"

extension TokenStore {
    
    // watch app request tokens to be pushed from the
    // phone. done when we launch the app.
    func requestTokens() {
        simpleSend(kRequestTokensMessage)
    }
    
    // invoked when we receive tokens from the phone, 
    // both when we've requested it and when they are 
    // automatically pushed.
    func receivePersistentTokensMessage(data:NSData) {
        
    }
    
}



// MARK: - WatchConnectivity functions

extension TokenStore : WCSessionDelegate {
    
    private var session:WCSession? {
        guard WCSession.isSupported() else {
            return nil
        }
        let session = WCSession.defaultSession()
        session.delegate = self // before activate
        session.activateSession()
        return session
    }

    func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
        // great, it's not overly interesting to
        // see whether we fail to connect since not connecting
        // is a "natural state" where the watch simply is
        // far away from the phone.
    }
    
    // validation free simple send and forget
    func simpleSend(name:String) {
        session?.sendMessage(["name":name], replyHandler: nil, errorHandler: nil)
    }
 
    // messages are on the form:
    // [
    //    name: "OTPPersistentTokensMessage"   // name of message
    //    data: ...                            // payload
    // ]
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let name = message["name"] as! String;
        switch name {
        case kPersistentTokensMessage:
            receivePersistentTokensMessage(message["data"] as! NSData)
        default:
            NSLog("Received message with unknown name ", name)
        }
    }

}
