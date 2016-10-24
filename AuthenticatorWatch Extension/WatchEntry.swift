//
//  WatchEntry.swift
//  Authenticator
//
//  Created by martin on 24/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation

struct WatchEntry : Component {

    var viewModel: WatchEntryViewModel {
        return WatchEntryViewModel()
    }
    
    enum Action {
        
    }
    enum Effect {
        
    }
    
    @warn_unused_result
    mutating func update(action: Action) -> Effect? {
        return nil
    }
    
    
}
