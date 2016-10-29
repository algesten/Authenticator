//
//  TokenStoreDelegate.swift
//  Authenticator
//
//  Created by martin on 2016-10-29.
//  Copyright © 2016 Matt Rubin. All rights reserved.
//

import Foundation
import OneTimePassword

protocol TokenStoreDelegate {

    func didAddToken(store: TokenStore, token: PersistentToken)
    func didResetTokens(store: TokenStore, tokens:[PersistentToken])
    func didSaveToken(store: TokenStore, token: PersistentToken)
    func didUpdatePersistenToken(store: TokenStore, token:PersistentToken)
    func didMoveTokenFromIndex(store: TokenStore, origin: Int, destination: Int)
    func didDeletePersistentToken(store: TokenStore, token:PersistentToken)

}
