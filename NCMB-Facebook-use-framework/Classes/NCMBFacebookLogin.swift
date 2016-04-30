//
//  NCMBFacebookLogin.swift
//  NCMB-Facebook-use-framework
//
//  Created by hiromi2424 on 04/29/2016.
//  Copyright (c) 2016 hiromi2424. All rights reserved.
//

import Accounts
import Alamofire
import Alamofire_SwiftyJSON
import NCMB
import PromiseKit

public class NCMBFacebookLogin {

    var appId: String
    var permissionsKey = ["email"]
    var audienceKey = ACFacebookAudienceFriends

    public init(appId: String, permissionsKey: [String]? = nil, audienceKey: String? = nil) {
        self.appId = appId
        if let permissionsKey = permissionsKey {
            self.permissionsKey = permissionsKey
        }
        if let audienceKey = audienceKey {
            self.audienceKey = audienceKey
        }
    }

    // Facebookでログインする
    public func loginWithFacebook(initUserCallback: ((NCMBUser, ACAccount) -> Void)? = nil) -> Promise<NCMBUser> {
        // Promise間で持ち回す変数定義
        var account: ACAccount!
        var oauthToken: String!
        return getFacebookAccount().then { (_account, credential) -> Promise<String> in
            account = _account
            oauthToken = credential.oauthToken
            return self.getFacebookActualId(oauthToken)
        }.then { (facebookId) -> Promise<NCMBUser> in
            return self.loginWithFacebookCredentials(facebookId, token: oauthToken, account: account)
        }.then { (user) -> Promise<NCMBUser> in
            return Promise<NCMBUser>(user)
        }

    }

    // FacebookアカウントをiOSのAccountsフレームワークを使って取得する
    // 取得できればACAccountのインスタンスをプロミス経由で返す
    // Facebookアカウントが複数ある場合は考慮していない（おそらくそのような状況は無い）
    public func getFacebookAccount() -> Promise<(ACAccount, ACAccountCredential)> {
        return Promise<(ACAccount, ACAccountCredential)>(resolvers: { (fulfill, reject) in
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
            var options = [String: AnyObject]()
            options[ACFacebookAppIdKey] = appId
            options[ACFacebookPermissionsKey] = permissionsKey
            options[ACFacebookAudienceKey] = audienceKey

            accountStore.requestAccessToAccountsWithType(accountType, options: options, completion: { (granted, error) in
                if granted {
                    print("Success to get facebook account")
                    let accounts: NSArray = accountStore.accountsWithAccountType(accountType)
                    if accounts.count >= 1 {
                        let account: ACAccount = accounts.lastObject as! ACAccount
                        fulfill((account, account.credential))
                    } else {
                        reject(NSError(domain: "AccountNotFound", code: 403, userInfo: nil))
                    }
                } else {
                    if error.domain == "" {

                    }
                    print("facebook login error:")
                    print(error)
                    reject(error)
                }
            })
        })
    }

    // AccountsフレームワークのFacebookIDが認証用に使えないことがあるので、GraphAPIを使ってグローバルに使えるIDを取得する
    public func getFacebookActualId(oauthToken: String) -> Promise<String> {
        let url = "https://graph.facebook.com/v2.6/me?access_token=\(oauthToken)"
        let req = Alamofire.request(.GET, url)
        return Promise<String>(resolvers: { (fulfill, reject) in
            req.responseSwiftyJSON({ (request, response, json, error) in
                if error == nil {
                    fulfill(json["id"].stringValue)
                } else {
                    reject(error!)
                }
            })
        })
    }

    // NCMBのAPIを使ってFacebookログインする
    public func loginWithFacebookCredentials(id: String, token: String, account: ACAccount?, initUserCallback: ((NCMBUser, ACAccount) -> Void)? = nil) -> Promise<NCMBUser> {
        return Promise<NCMBUser> { (fulfill, reject) in
            let user = NCMBUser()
            let calendar = NSCalendar.currentCalendar()
            // 正常な有効期限は取得できないので、仮に20年後とする
            let expiryDate = calendar.dateByAddingUnit(.Year, value: 20, toDate: NSDate(), options: [])!
            let facebookInfo: [NSString:NSMutableDictionary] = [
                "facebook": [
                    "id": id,
                    "access_token": token,
                    "expiration_date": expiryDate
                ]
            ]

            // ここでFaebook情報から名前等を入れる
            if let accountData = account {
                // user.setObject(accountData.userFullName, forKey: "userName")
                initUserCallback?(user, accountData)
            }
            user.signUpWithFacebookToken(facebookInfo as [NSString : NSMutableDictionary], block: { (error) in
                if error == nil {
                    fulfill(NCMBUser.currentUser())
                } else {
                    reject(error!)
                    print("ncmb error!")
                    print(error!)
                }
            })
        }
    }

}