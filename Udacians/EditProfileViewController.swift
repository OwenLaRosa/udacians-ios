//
//  EditProfileViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/5/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profilePictureButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    @IBOutlet weak var siteTextField: UITextField!
    
    @IBOutlet weak var blogTextField: UITextField!
    
    @IBOutlet weak var linkedinTextField: UITextField!
    
    @IBOutlet weak var twitterTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    let invalidUrlColor = UIColor(colorLiteralRed: 255.0/255.0, green: 138.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    
    var newImage: UIImage!
    
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    var basicRef: FIRDatabaseReference!
    var profileRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        let userRef = ref.child("users").child(getUid())
        basicRef = userRef.child("basic")
        profileRef = userRef.child("profile")
        
        basicRef.observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? [String : String] else { return }
            if let url = value["photo"] {
                if let storedImage = WebImageCache.shared.image(with: self.getUid()) {
                    self.profilePictureButton.setImage(storedImage, for: .normal)
                } else {
                    _ = WebImageCache.shared.downloadImage(at: url) {imageData in
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: self.getUid())
                        DispatchQueue.main.async {
                            self.profilePictureButton.setImage(imageData, for: .normal)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
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
            let imagesReference = storageRef.child(getUid()).child("public").child("images")
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
            profilePictureButton.setImage(image, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        titleTextField.resignFirstResponder()
        aboutTextView.resignFirstResponder()
        siteTextField.resignFirstResponder()
        blogTextField.resignFirstResponder()
        twitterTextField.resignFirstResponder()
        linkedinTextField.resignFirstResponder()
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        var heightToScroll: CGFloat = 0.0
        if let activeTextField = getActiveTextField() {
            heightToScroll = activeTextField.frame.origin.y
        } else if aboutTextView.isFirstResponder {
            heightToScroll = aboutTextView.frame.origin.y
        }
        let keyboardOffset = getKeyboardOffset(notification: notification)
        let keyboardYOrigin = view.frame.height - keyboardOffset
        // move the bottom of the scroll view above the top of the keyboard
        scrollViewBottom.constant = -keyboardOffset
        if heightToScroll > keyboardYOrigin {
            // text field is near the bottom of the screen and should be scrolled into view
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height), animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollViewBottom.constant = 0
    }
    
    private func getKeyboardOffset(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.contentSize.height = twitterTextField.frame.origin.y + twitterTextField.frame.height + 8
    }
    
    /// return the text field that is being edited
    /// if no text field is being edited, return nil
    private func getActiveTextField() -> UITextField! {
        if titleTextField.isEditing {
            return titleTextField
        }
        if siteTextField.isEditing {
            return siteTextField
        }
        if blogTextField.isEditing {
            return blogTextField
        }
        if linkedinTextField.isEditing {
            return linkedinTextField
        }
        if twitterTextField.isEditing {
            return twitterTextField
        }
        return nil
    }
    
}
