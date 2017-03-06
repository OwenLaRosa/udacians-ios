//
//  EditProfileViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/5/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePictureButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var siteTextField: UITextField!
    
    @IBOutlet weak var blogTextField: UITextField!
    
    @IBOutlet weak var linkedinTextField: UITextField!
    
    @IBOutlet weak var twitterTextField: UITextField!
    
    var ref: FIRDatabaseReference!
    let userId = "3050228546"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(userId)
        let basicRef = userRef.child("basic")
        let profileRef = userRef.child("profile")
        
        basicRef.observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? [String : String] else { return }
            if let url = value["photo"] {
                if let storedImage = WebImageCache.shared.image(with: self.userId) {
                    self.profilePictureButton.image = storedImage
                } else {
                    _ = WebImageCache.shared.downloadImage(at: url) {imageData in
                        DispatchQueue.main.async {
                            WebImageCache.shared.storeImage(image: imageData, withIdentifier: self.userId)
                            self.profilePictureButton.image = imageData
                        }
                    }
                }
            }
            self.titleTextField.text = value["title"] ?? ""
            self.aboutTextView.text = value["about"] ?? ""
        })
        profileRef.observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? [String: String] else { return }
            self.siteTextField.text = value["site"] ?? ""
            self.blogTextField.text = value["blog"] ?? ""
            self.linkedinTextField.text = value["linkedin"] ?? ""
            self.twitterTextField.text = value["twitter"] ?? ""
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseProfilePicture(_ sender: UIButton) {
    }
    
    
}
