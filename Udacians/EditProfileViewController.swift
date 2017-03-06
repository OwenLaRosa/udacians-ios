//
//  EditProfileViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/5/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePictureButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var siteTextField: UITextField!
    
    @IBOutlet weak var blogTextField: UITextField!
    
    @IBOutlet weak var linkedinTextField: UITextField!
    
    @IBOutlet weak var twitterTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let invalidUrlColor = UIColor(colorLiteralRed: 255.0/255.0, green: 138.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    
    var newImage: UIImage!
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var basicRef: FIRDatabaseReference!
    var profileRef: FIRDatabaseReference!
    let userId = "3050228546"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        let userRef = ref.child("users").child(userId)
        basicRef = userRef.child("basic")
        profileRef = userRef.child("profile")
        
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
        if let title = titleTextField.text {
            basicRef.child("title").setValue(title)
        }
        if let about = aboutTextView.text {
            basicRef.child("about").setValue(about)
        }
        if let site = siteTextField.text {
            if let url = Utils.validateUrl(url: site) {
                profileRef.child("site").setValue(url)
                siteTextField.backgroundColor = UIColor.white
            } else {
                siteTextField.backgroundColor = invalidUrlColor
            }
        }
        if let blog = blogTextField.text {
            if let url = Utils.validateUrl(url: blog) {
                profileRef.child("blog").setValue(url)
                blogTextField.backgroundColor = UIColor.white
            } else {
                blogTextField.backgroundColor = invalidUrlColor
            }
        }
        if let linkedin = linkedinTextField.text {
            if let url = Utils.validateUrl(url: linkedin) {
                profileRef.child("linkedin").setValue(url)
                linkedinTextField.backgroundColor = UIColor.white
            } else {
                linkedinTextField.backgroundColor = invalidUrlColor
            }
        }
        if let twitter = twitterTextField.text {
            if let url = Utils.validateUrl(url: twitter) {
                profileRef.child("twitter").setValue(url)
                twitterTextField.backgroundColor = UIColor.white
            } else {
                twitterTextField.backgroundColor = invalidUrlColor
            }
        }
        if let imageContents = newImage {
            let imagesReference = storageRef.child(userId).child("public").child("images")
            setUIState(enabled: false)
            Utils.uploadImage(image: imageContents, toReference: imagesReference) { (url) in
                if url != nil {
                    self.basicRef.child("photo").setValue(url)
                }
                self.setUIState(enabled: true)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func chooseProfilePicture(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            return
        }
        let imagePickingAlert = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)
        imagePickingAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        imagePickingAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        imagePickingAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(imagePickingAlert, animated: true, completion: nil)
    }
    
    private func setUIState(enabled: Bool) {
        profilePictureButton.isEnabled = enabled
        titleTextField.isEnabled = enabled
        aboutTextView.isEditable = enabled
        aboutTextView.isSelectable = enabled
        aboutTextView.isScrollEnabled = enabled
        siteTextField.isEnabled = enabled
        blogTextField.isEnabled = enabled
        linkedinTextField.isEnabled = enabled
        twitterTextField.isEnabled = enabled
        saveButton.isEnabled = enabled
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = image
            profilePictureButton.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
}
