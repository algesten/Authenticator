//
//  OTPAppDelegate.swift
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

import UIKit
import OneTimePassword
import SVProgressHUD

@UIApplicationMain
class OTPAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)

    let app = AppController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // swiftlint:disable:next force_unwrapping
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!], forState: UIControlState.Normal)

        // Restore white-on-black style
        SVProgressHUD.setDefaultStyle(.Dark)
        SVProgressHUD.setMinimumDismissTimeInterval(1)

        self.window?.rootViewController = app.rootViewController
        self.window?.makeKeyAndVisible()

        // connect to watch, if available
        app.activateWCSession()

        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let token = Token(url: url) {
            let message = "Do you want to add a token for “\(token.name)”?"

            let alert = UIAlertController(title: "Add Token", message: message, preferredStyle: .Alert)

            let acceptHandler: (UIAlertAction) -> Void = { [weak app] (_) in
                app?.addTokenFromURL(token)
            }

            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: acceptHandler))

            // TODO: Fix the confirmation alert presentation when a modal is open.
            window?.rootViewController?
                .presentViewController(alert, animated: true, completion: nil)

            return true
        }

        return false
    }
}
