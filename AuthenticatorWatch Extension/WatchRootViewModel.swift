//
//  WatchRootViewModel.swift
//  Authenticator
//
//  Created by martin on 23/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation

struct WatchRootViewModel {
    let tokenList: WatchTokenList.ViewModel
    let modal: ModalViewModel
    
    enum ModalViewModel {
        case None
        case EntryView
    }
}
