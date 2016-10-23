//
//  WatchAppController.swift
//  Authenticator
//
//  Created by martin on 23/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation
import UIKit
import OneTimePassword

class WatchAppController {
    private let store: WatchTokenStore
    private var component: WatchRoot
    
    init() {
        store = WatchTokenStore(
            userDefaults: NSUserDefaults.standardUserDefaults()
        )
        component = WatchRoot(persistentTokens: store.persistentTokens)
    }
    
    private func handleAction(action: WatchRoot.Action) {
        let sideEffect = component.update(action)
        if let effect = sideEffect {
            handleEffect(effect)
        }
    }
    
    private func handleEffect(effect: WatchRoot.Effect) {
        switch effect {
        case .RequestTokens():
            store.requestTokens()
        case let .UpdatePersistentTokens(tokens, success, failure):
            do {
                try store.savePersistentTokens(tokens)
                handleAction(success(store.persistentTokens))
            } catch {
                handleAction(failure(error))
            }
        }
    }
    

}
