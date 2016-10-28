//
//  WatchRoot.swift
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

struct WatchRoot : Component {
    private var tokenList: WatchTokenList
    private var modal: WatchModal
 
    private enum WatchModal {
        case None
        case EntryView(WatchEntry)
        
        var viewModel: WatchRootViewModel.ModalViewModel {
            switch self {
            case .None:
                return .None
            case .EntryView(let component):
                guard let viewModel = component.viewModel else {
                    return .None
                }
                return .EntryView(viewModel)
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
        case EntryAction(WatchEntry.Action)
        case TokenStoreUpdated([PersistentToken])
    }
    
    enum Effect {
        case RefreshTokenList([PersistentToken])
    }
    
    @warn_unused_result
    mutating func update(action: Action) -> Effect? {
        switch action {
        case .TokenListAction(let action):
            return handleTokenListAction(action)
        case .EntryAction(let action):
            return handleWatchEntryAction(action)
        case .TokenStoreUpdated(let tokens):
            return .RefreshTokenList(tokens)
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
    
    @warn_unused_result
    private mutating func handleWatchEntryAction(action: WatchEntry.Action) -> Effect? {
        guard case .EntryView(var watchEntry) = modal else {
            return nil
        }
        let effect = watchEntry.update(action)
        if let effect = effect {
            return handleWatchEntryEffect(effect)
        }
        return nil
    }
    
    @warn_unused_result
    private mutating func handleTokenListEffect(effect: WatchTokenList.Effect) -> Effect? {
        switch effect {
        case .BeginShowEntry(let token):
            modal = .EntryView(WatchEntry(persistentToken:token))
            return nil
        }
    }

    @warn_unused_result
    private mutating func handleWatchEntryEffect(effect: WatchEntry.Effect) -> Effect? {
        return nil
    }
    
}
