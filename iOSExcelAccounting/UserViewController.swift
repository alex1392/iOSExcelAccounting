//
//  UserViewController.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/5/2.
//  Copyright © 2020 cyc. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, ViewControllerWithSpinner {

    public let spinner = SpinnerViewController()
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // try to get data immediately
        connect(self)
    }
    
    @IBAction func connect(_ sender: Any) {
        DataManager.getList(controller: self) { (error) in
            guard error == nil else {
                // if not successful, just stay here
                // display user information
                GraphManager.instance.getMe { (user, error) in
                    guard let user = user, error == nil else {
                        AlertManager.showWithOK(controller: self, title: "使用者資訊擷取失敗", message: "錯誤訊息： \(error.debugDescription)")
                        return
                    }
                    self.userName.text = user.displayName ?? "No user name available"
                    self.userEmail.text = user.mail ?? user.userPrincipalName ?? "No email address available"
                }
                return
            }
            // if get data successfully
            self.performSegue(withIdentifier: "gotData", sender: self)
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        AuthenticationManager.instance.signOut()
        self.performSegue(withIdentifier: "userSignedOut", sender: self)
    }
}
