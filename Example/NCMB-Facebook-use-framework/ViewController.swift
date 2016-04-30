//
//  ViewController.swift
//  NCMB-Facebook-use-framework
//
//  Created by hiromi2424 on 04/29/2016.
//  Copyright (c) 2016 hiromi2424. All rights reserved.
//

import UIKit
import NCMB
import NCMB_Facebook_use_framework
import PromiseKit

class ViewController: UIViewController {

    @IBOutlet var facebookAppIDField: UITextField!
    @IBOutlet var NCMBAppKeyField: UITextField!
    @IBOutlet var NCMBClientKeyField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var userInfoView: UITextView!

    var user: NCMBUser? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresh()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 画面更新
    func refresh() {
        self.loginButton.setTitle(isLoggedIn() ? "Logout" : "Login", forState: .Normal)
        self.userInfoView.text = self.user?.description ?? "Not Logged In"
    }

    // ログインしているかはself.userで管理する
    func isLoggedIn() -> Bool {
        return self.user != nil
    }

    // メッセージ表示
    func alert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let dismiss: (UIAlertAction) -> Void = { (action) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: dismiss))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: dismiss))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func loginButton(sender: UIButton) {
        // ログインしていたらログアウト
        guard !isLoggedIn() else {
            // NCMB側でもログアウトする
            NCMBUser.logOut()
            self.user = nil
            self.refresh()
            return
        }

        // フォーム入力チェック
        if facebookAppIDField.text == "" {
            alert("Specify your Facebook App ID")
        } else if NCMBAppKeyField.text == "" || NCMBClientKeyField.text == ""  {
            alert("Specify your NCMB Credentials")
        } else {
            // 多重に押せないようにする
            self.loginButton.enabled = false
            // NCMB設定
            NCMB.setApplicationKey(NCMBAppKeyField.text!, clientKey: NCMBClientKeyField.text!)
            // ログインする
            NCMBFacebookLogin(appId: facebookAppIDField.text!).loginWithFacebook({ (user, account) in
                user.setObject(account.valueForKeyPath("properties.ACUIDisplayUsername"), forKey: "mailAddress")
            }).then({ (user) -> Void in
                self.user = user
            }).always({
                self.loginButton.enabled = true
                self.refresh()
            }).error({ (error) -> Void in
                self.alert(String(error))
            })
        }

    }
}

