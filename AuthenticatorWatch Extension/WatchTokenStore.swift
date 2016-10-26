//
//  WatchTokenStore.swift
//  Authenticator
//
//  Copyright (c) 2013-2016 Authenticator authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
