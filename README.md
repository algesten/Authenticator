# Authenticator
### Two-Factor Authentication Client for iOS.

[<img src="https://badge.fury.io/gh/mattrubin%2Fauthenticator@2x.png" alt="GitHub version" height="18px">](http://badge.fury.io/gh/mattrubin%2Fauthenticator)
[![Build Status](https://travis-ci.org/mattrubin/authenticator.svg?branch=master)](https://travis-ci.org/mattrubin/authenticator)


Authenticator is a simple, free, and open source [two-factor authentication](https://en.wikipedia.org/wiki/Two-factor_authentication) app. It helps keep your online accounts secure by generating unique one-time passwords, which you use in combination with your other passwords to log into supporting websites. The simple combination of the password in your head and the rotating passwords generated by the app make it much harder for anyone but you to access your accounts.

- Easy: Simple setup via QR code, ["otpauth://" URL](https://code.google.com/p/google-authenticator/wiki/KeyUriFormat), or manual entry
- Secure: All data is stored in encrypted form on the iOS keychain
- Compatible: Full support for [time-based](https://tools.ietf.org/html/rfc6238) and [counter-based](https://tools.ietf.org/html/rfc4226) one-time passwords as standardized in RFC 4226 and 6238
- Off the Grid: The app never connects to the internet, and your secret keys never leave your device.


## License

This project is made available under the terms of the [MIT License](http://opensource.org/licenses/MIT).

The modern Authenticator grew out of the abandoned source for [Google Authenticator](https://code.google.com/p/google-authenticator/) for iOS. The original Google code on which this project was based is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
