//
//  LoginViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 10/27/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import UIKit
import MarkupKit

class LoginViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var noticeLabel: UILabel!
    
    override func loadView() {
        view = LMViewBuilder.view(withName: "LoginViewController", owner: self, root: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login() {
        
    }

}

