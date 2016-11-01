//
//  LoginViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 10/27/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import UIKit
import MarkupKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

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
        _ = UdacityClient.shared.getToken(email: emailTextField.text!, password: passwordTextField.text!) {success, code in
            if success {
                // once we have the token, use it to authenticate with firebase
                FIRAuth.auth()?.signIn(withCustomToken: UdacityClient.shared.token, completion: {authData, error in
                    if error != nil {
                        print("login failed: \(error)")
                    } else {
                        print("login successful: \(authData)")
                        _ = UdacityClient.shared.getDataForUserId(userId: authData!.uid) {user, code in
                            print("response code: \(code)")
                            print("user: \(user?.firstName) \(user?.lastName) \(user?.profile?.enrollments)")
                        }
                    }
                })
            
            } else {
                print("login failed \(code)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // indent cursor from the left edge
        emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
    }

}
