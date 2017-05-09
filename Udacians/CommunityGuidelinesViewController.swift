//
//  CommunityGuidelinesViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 5/9/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class CommunityGuidelinesViewController: UIViewController {
    
    @IBAction func agreeToTerms(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(true, forKey: "eula_agreed")
        dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
}
