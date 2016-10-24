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
    private let store: TokenStore
    private var component: WatchRoot {
        didSet {
            view.updateWithViewModel(component.viewModel)
        }
    }
    private lazy var view: WatchRootViewController = {
        return WatchRootViewController(
            viewModel: self.component.viewModel,
            dispatchAction: self.handleAction
        )
    }()
    
    init() {
        do {
            try store = TokenStore(
                keychain: Keychain.sharedInstance,
                userDefaults: NSUserDefaults.standardUserDefaults()
            )
        } catch {
            // If the TokenStore could not be created, the watch app is unusable.
            fatalError("Failed to load token store: \(error)")
        }
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
        case let .UpdateTokens(tokens, success, failure):
            do {
                try store.resetTokens(tokens)
                handleAction(success(store.persistentTokens))
            } catch {
                handleAction(failure(error))
            }
        }
    }
    

}
