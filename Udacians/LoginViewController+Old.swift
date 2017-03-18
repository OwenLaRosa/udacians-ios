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

class LoginViewController_Old: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var noticeLabel: UILabel!
    
    override func loadView() {
        view = LMViewBuilder.view(withName: "LoginViewController", owner: self, root: nil)
        
        // automatically attempt sign in if there's a valid token
        if let token = UserDefaults.standard.string(forKey: "token") {
            print("token: \(token)")
            FIRAuth.auth()?.signIn(withCustomToken: token, completion: {authData, error in
                if error != nil {
                    // token expired, login again
                    print("token expired")
                } else {
                    // token expired, login again
                    print("successfully logged in")
                    /*// get a reference to the signed in user
                    let userRef = FIRDatabase.database().reference(withPath: "users").child(authData!.uid)
                    let basicRef = userRef.child("basic")
                    basicRef.observe(.value, with: {snapshot in
                        // read and save users' profile info
                        let root = snapshot.value as! [String: Any]
                        let user = User(userId: authData!.uid, firstName: root["firstName"] as! String, lastName: root["lastName"] as! String)
                        print("user: \(user.name)")
                    })*/
                    self.performSegue(withIdentifier: "ShowMainView", sender: nil)
                }
            })
        } else {
            // no token yet, log in
            print("no token")
        }
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
                        UserDefaults.standard.set(UdacityClient.shared.token, forKey: "token")
                        print("login successful: \(authData)")
                        _ = UdacityClient.shared.getDataForUserId(userId: authData!.uid) {user, code in
                            // sync user's basic profile information
                            let usersRef = FIRDatabase.database().reference(withPath: "users")
                            let name = usersRef.child(authData!.uid).child("basic").child("name")
                            name.setValue(user!.name)
                            // sync user's current enrollments
                            let enrollments = usersRef.child(authData!.uid).child("enrollments")
                            enrollments.setValue(user!.profile?.enrollmentsDictionary)
                            // present the app's main screen
                            self.performSegue(withIdentifier: "ShowMainView", sender: nil)
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
