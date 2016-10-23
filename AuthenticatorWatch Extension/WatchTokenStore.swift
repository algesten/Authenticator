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

let kRequestTokensMessage = "OTPRequestTokensMessage"
let kPersistentTokensMessage = "OTPPersistentTokensMessage"

class WatchTokenStore : NSObject {
    
    private let userDefaults: NSUserDefaults
    private(set) var persistentTokens: [PersistentToken]
    
    // Throws an error if the initial state could not be loaded from the keychain.
    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
        self.persistentTokens = userDefaults.allPersistentTokens()
    }
    
    func savePersistentTokens(tokens:[PersistentToken]) throws {
        try self.userDefaults.savePersistentTokens(tokens)
    }
    
    func requestTokens() {
        simpleSend(kRequestTokensMessage)
    }
    
    func receivePersistentTokensMessage(data:NSData) {
        
    }

}

// MARK: - WatchConnectivity functions

extension WatchTokenStore : WCSessionDelegate {
    
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
        // great
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


// MARK: - Token UserDefaultsPersistence

private let kPersistentTokensArray = "OTPPersistentTokensArray"

private extension NSUserDefaults {
    
    
    func savePersistentTokens(tokens:[PersistentToken]) throws {
        // turn into array of [NSData,String] pairs for each token
        let arr:NSArray = try tokens.map() {
            return [$0.identifier, try $0.token.toURL()]
        }
        setObject(arr, forKey: kPersistentTokensArray)
    }
    
    
    func allPersistentTokens() -> [PersistentToken] {
        guard let arr = arrayForKey(kPersistentTokensArray) else {
            // if we have no stored data return empty array
            return []
        }
        return arr.map({
            let pair = $0 as! [AnyObject]
            let identifier = pair[0] as! NSData
            let urlStr = pair[1] as! String
            guard let url = NSURL(string: urlStr) else {
                return nil  // broken string representation?
            }
            guard let token = Token(url: url) else {
                return nil  // broken url?
            }
            return PersistentToken(token: token, identifier: identifier)
        }).flatMap() { $0 } // filter nil
    }
    
    
}
