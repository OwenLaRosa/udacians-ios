//
//  LoginViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/18/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var centerStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        spinner.isHidden = true
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        login()
    }
    
    @IBAction func dismissKeyboardGesture(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func login() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        configureUI(enabled: false)
        let email = emailTextField.text!
        let password = passwordTextField.text!
        _ = UdacityClient.shared.getToken(email: email, password: password, completionHandler: {success, code in
            if !success {
                print("Failed to get XSRF token, status code: \(code)")
                return
            }
            FIRAuth.auth()?.signIn(withCustomToken: UdacityClient.shared.token, completion: {user, error in
                if let userId = user?.uid {
                    UdacityClient.shared.userId = userId
                    UserDefaults.standard.set(UdacityClient.shared.token, forKey: "token")
                    print("Successfully authenticated with Firebase")
                    _ = UdacityClient.shared.syncProfileData() {success, code in
                        if success {
                            print("successfully synced profile data")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.configureUI(enabled: true)
                    }
                }
            })
        })
    }
    
    func configureUI(enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        spinner.isHidden = enabled
        if enabled {
            spinner.stopAnimating()
        } else {
            spinner.startAnimating()
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            login()
        }
        return true
    }
    
}
