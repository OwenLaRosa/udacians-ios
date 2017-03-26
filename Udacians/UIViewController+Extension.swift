//
//  UIViewController+Extension.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/26/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    
    func getUid() -> String {
        return FIRAuth.auth()!.currentUser!.uid
    }
    
}
