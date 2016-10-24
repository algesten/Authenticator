//
//  WatchEntryViewController.swift
//  Authenticator
//
//  Created by martin on 24/10/2016.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import WatchKit
import Foundation

class WatchEntryViewController: WKInterfaceController {

    // current instance (if presented)
    static var instance:WatchEntryViewController?
    
    
    override func willActivate() {
        super.willActivate()
        WatchEntryViewController.instance = self
    }
    
    override func didDeactivate() {
        WatchEntryViewController.instance = nil
        super.didDeactivate()
    }

}
