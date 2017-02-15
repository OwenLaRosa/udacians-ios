//
//  MessageViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/13/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension MessageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
