//
//  WatchRoot.swift
//  Authenticator
//
//  Created by martin on 23/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation
import OneTimePassword

struct WatchRoot : Component {
    private var tokenList: WatchTokenList
    private var modal: WatchModal
 
    private enum WatchModal {
        case None
        case EntryView
        
        var viewModel: WatchRootViewModel.ModalViewModel {
            switch self {
            case .None:
                return .None
            case .EntryView:
                return .EntryView
            }
        }
    }

    init(persistentTokens: [PersistentToken]) {
        tokenList = WatchTokenList(persistentTokens: persistentTokens)
        modal = .None
    }
    
}

// MARK: View

extension WatchRoot {
    
    typealias ViewModel = WatchRootViewModel
    
    var viewModel: ViewModel {
        return ViewModel(
            tokenList: tokenList.viewModel,
            modal: modal.viewModel
        )
    }
}

// MARK: Update

extension WatchRoot {
    enum Action {
        case TokenListAction(WatchTokenList.Action)

        case RequestTokens
        case ReceiveTokens([Token])
    }
    
    enum Effect {
        case RequestTokens
        case UpdateTokens([Token],
            success: ([PersistentToken]) -> Action,
            failure: (ErrorType) -> Action)
    }
    
    @warn_unused_result
    mutating func update(action: Action) -> Effect? {
        switch action {
        case .TokenListAction(let action):
            return handleTokenListAction(action)
        case .RequestTokens():
            return handleRequestTokens()
        case .ReceiveTokens(let tokens):
            return handleTokens(tokens)
        }
    }
    
    @warn_unused_result
    private mutating func handleTokenListAction(action: WatchTokenList.Action) -> Effect? {
        let effect = tokenList.update(action)
        if let effect = effect {
            return handleTokenListEffect(effect)
        }
        return nil
    }
        
    private mutating func handleRequestTokens() -> Effect? {
        
        return nil
    }
    
    private mutating func handleTokens(tokens:[Token]) -> Effect? {
        return nil
    }
        
    @warn_unused_result
    private mutating func handleTokenListEffect(effect: WatchTokenList.Effect) -> Effect? {
        return nil
    }
        
        
    
}

private func compose<A, B, C>(transform: A -> B, _ handler: B -> C) -> A -> C {
    return { handler(transform($0)) }
}
