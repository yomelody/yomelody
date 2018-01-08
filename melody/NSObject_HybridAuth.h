//
//  NSObject_HybridAuth.h
//  melody
//
//  Created by coding Brains on 28/08/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject ()
import Foundation
import Auth0

@objc class HybridAuth: NSObject {
    
    private let authentication = Auth0.authentication()
    
    static func resume(_ url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return Auth0.resumeAuth(url, options: options)
    }
    
    func showLogin(withScope scope: String, connection: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        guard let clientInfo = plistValues(bundle: Bundle.main) else { return }
        let webAuth = Auth0.webAuth()
        
        if let connection = connection {
            _ = webAuth.connection(connection)
        }
        
        webAuth
        .scope(scope)
        .audience("https://" + clientInfo.domain + "/userinfo")
        .start {
            switch $0 {
            case .failure(let error):
                callback(error, nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }
    
    func userInfo(accessToken: String, callback: @escaping (Error?, UserInfo?) -> ()) {
        self.authentication.userInfo(withAccessToken: accessToken).start {
            switch $0 {
            case .success(let profile):
                callback(nil, profile)
            case .failure(let error):
                callback(error, nil)
            }
        }
    }
    
    func login(withUsernameOrEmail username: String, password: String, realm: String, audience: String? = nil, scope: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.login(usernameOrEmail: username, password: password, realm: realm, audience: audience, scope: scope).start {
            switch $0 {
            case .failure(let error):
                callback(error, nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }
    
    func signUp(withEmail email: String, username: String?, password: String, connection: String, userMetadata: [String: Any]?, scope: String, parameters: [String: Any], callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.signUp(email: email, username: username, password: password, connection: connection, userMetadata: userMetadata, scope: scope, parameters: parameters).start {
            switch $0 {
            case .failure(let error):
                callback(error, nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }
    
    func renew(withRefreshToken refreshToken: String, scope: String?, callback: @escaping (Error?, Credentials?) -> ()) {
        self.authentication.renew(withRefreshToken: refreshToken, scope: scope).start {
            switch $0 {
            case .failure(let error):
                callback(error, nil)
            case .success(let credentials):
                callback(nil, credentials)
            }
        }
    }
    
    func userProfile(withIdToken idToken: String, userId: String, callback: @escaping (Error?, [String: Any]?) -> ()) {
        Auth0
        .users(token: idToken)
        .get(userId, fields: [], include: true)
        .start {
            switch $0 {
            case .success(let user):
                callback(nil, user)
                break
            case .failure(let error):
                callback(error, nil)
                break
            }
        }
    }
    
    func patchProfile(withIdToken idToken: String, userId: String, metaData: [String: Any], callback: @escaping (Error?, [String: Any]?) -> ()) {
        Auth0
        .users(token: idToken)
        .patch(userId, userMetadata: metaData)
        .start {
            switch $0 {
            case .success(let user):
                callback(nil, user)
            case .failure(let error):
                callback(error, nil)
            }
        }
    }
    
    func linkUserAccount(withIdToken idToken: String, userId: String, otherAccountToken: String, callback: @escaping (Error?, [[String: Any]]?) -> ()) {
        Auth0
        .users(token: idToken)
        .link(userId, withOtherUserToken: otherAccountToken)
        .start {
            switch $0 {
            case .success(let payload):
                callback(nil, payload)
            case .failure(let error):
                callback(error, nil)
            }
        }
    }
    
    func unlinkUserAccount(withIdToken idToken: String, userId: String, identity: Identity, callback: @escaping (Error?, [[String: Any]]?) -> ()) {
        Auth0
        .users(token: idToken)
        .unlink(identityId: identity.identifier, provider: identity.provider, fromUserId: userId)
        .start {
            switch $0 {
            case .success(let payload):
                callback(nil, payload)
            case .failure(let error):
                callback(error, nil)
            }
        }
    }
    
}

func plistValues(bundle: Bundle) -> (clientId: String, domain: String)? {
    guard
    let path = bundle.path(forResource: "Auth0", ofType: "plist"),
    let values = NSDictionary(contentsOfFile: path) as? [String: Any]
    else {
        print("Missing Auth0.plist file with 'ClientId' and 'Domain' entries in main bundle!")
        return nil
    }
    
    guard
    let clientId = values["ClientId"] as? String,
    let domain = values["Domain"] as? String
    else {
        print("Auth0.plist file at \(path) is missing 'ClientId' and/or 'Domain' entries!")
        print("File currently has the following entries: \(values)")
        return nil
    }
    return (clientId: clientId, domain: domain)
}
@end
