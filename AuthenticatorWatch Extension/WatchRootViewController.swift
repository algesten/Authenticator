//
//  WatchRootViewController.swift
//  Authenticator
//
//  Created by martin on 24/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation

// this is a placeholder to make the structure of the watch app
// analogous to that of the main iphone app
class WatchRootViewController {
    
    private var currentViewModel:WatchRoot.ViewModel

    private var tokenListViewController: WatchTokenListViewController
    
    private let dispatchAction: (WatchRoot.Action) -> ()
    
    
    init(viewModel: WatchRoot.ViewModel, dispatchAction: (WatchRoot.Action) -> ()) {
        self.currentViewModel = viewModel
        self.dispatchAction = dispatchAction
        // fish out the singleton from the storyboard
        self.tokenListViewController = WatchTokenListViewController.instance
    }
    
}



extension WatchRootViewController {
    func updateWithViewModel(viewModel: WatchRoot.ViewModel) {
        tokenListViewController.updateWithViewModel(viewModel.tokenList)
        
        switch viewModel.modal {
        case .None:
            if let vc = WatchEntryViewController.instance {
                // it is visible and presenting, dismiss it
                vc.dismissController()
            }
        case .EntryView:
            if WatchEntryViewController.instance == nil {
                // it is not presenting, make it.
                
            }
        }
    }
}
