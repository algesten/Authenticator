//
//  WatchEntryViewController.swift
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

import WatchKit
import Foundation
import CoreGraphics

class WatchEntryViewController: WKInterfaceController {

    // hack way of passing arguments into this controller
    static var viewModel:WatchEntry.ViewModel?
    static var dispatchAction:((WatchEntry.Action) -> ())?
    
    // current instance (if presented)
    static var instance:WatchEntryViewController?
    
    @IBOutlet weak var issuerLabel: WKInterfaceLabel!
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var progressGroup: WKInterfaceGroup!
    @IBOutlet weak var passwordLabel: WKInterfaceLabel!

    @IBOutlet weak var nohotpGroup: WKInterfaceGroup!
    @IBOutlet weak var passwordGroup: WKInterfaceGroup!

    // timer if we have time based view
    var timer:NSTimer?
    
    var onWillDisappear:(() -> ())?
    
    override func awakeWithContext(context: AnyObject?) {

        // singleton
        WatchEntryViewController.instance = self
        
        // there really ought to be a viewModel there
        guard let viewModel = WatchEntryViewController.viewModel else {
            return
        }
        guard let dispatchAction = WatchEntryViewController.dispatchAction else {
            return
        }
        updateWithViewModel(viewModel, dispatchAction: dispatchAction)

    }
    
    override func willDisappear() {
        super.willDisappear()
        WatchEntryViewController.instance = nil
        timer?.invalidate()
        timer = nil
        onWillDisappear?()
    }

}

// MARK: - Presenter

extension WatchEntryViewController {
    func updateWithViewModel(viewModel: WatchEntry.ViewModel, dispatchAction:(WatchEntry.Action) -> ()) {

        // stop a (very not likely) previous timer
        timer?.invalidate()
        timer = nil
        
        if viewModel.isHOTP {
            // XXX remove when we support HOTP
            nohotpGroup.setHidden(false)
            passwordGroup.setHidden(true)
            return
        } else {
            nohotpGroup.setHidden(true)
            passwordGroup.setHidden(false)
        }
        
        issuerLabel.setText(viewModel.issuer)
        nameLabel.setText(viewModel.name)
        passwordLabel.setText(viewModel.password)
        onWillDisappear = {
            dispatchAction(.Dismiss)
        }
        
        if viewModel.progress == nil {
            // nil means there is no timer based thing to show
            progressGroup.setHidden(true)
        } else {
            progressGroup.setHidden(false)
            // start a timer that repeatedly will update the progress
            timer = NSTimer.scheduledTimerWithTimeInterval(0.05, repeats: true) { [weak self] _ in
                guard let progress = viewModel.progress else {
                    return
                }
                self?.passwordLabel.setText(viewModel.password)
                self?.drawProgress(progress)
            }
        }
        
    }
    func updateProgress(viewModel: WatchEntry.ViewModel) {
    }
}

// MARK: - Progress line

extension WatchEntryViewController {
    
    func drawProgress(progress:Double) {
        let width = self.contentFrame.size.width
        
        let size = CGSize(width:width, height:4.0)
        
        
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // Setup appearance
        CGContextSetFillColorWithColor(context, UIColor.otpLightColor.CGColor)

        // fill a rectangle of the progress
        CGContextFillRect(context, CGRectMake(0, 0, CGFloat(1 - progress) * width, 4.0))
        
        // Convert to UIImage
        let cgimage = CGBitmapContextCreateImage(context)!
        let uiimage = UIImage(CGImage: cgimage)
        
        // and slot into our holder group
        progressGroup.setBackgroundImage(uiimage)
        
        // End the graphics context
        UIGraphicsEndImageContext()
    }
    
}

