//
//  UIViewController+Convenience.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/11/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}


