//
//  WritePostViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 3/5/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase

class WritePostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoAlbumButton: UIBarButtonItem!
    @IBOutlet weak var clearImageButton: UIBarButtonItem!
    @IBOutlet weak var toolbarBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var contentImageHeight: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    // true if posts are for user profile, false if for events
    var isUserPosts = true
    var eventId: String!
    
    var ref: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    var postLinksRef: FIRDatabaseReference!
    
    var storageRef: FIRStorageReference!
    var imageStorageRef: FIRStorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        if isUserPosts {
            postsRef = ref.child("posts")
            postLinksRef = ref.child("users").child(getUid()).child("posts")
        } else {
            postsRef = ref.child("events").child(eventId).child("posts")
        }
        storageRef = FIRStorage.storage().reference()
        imageStorageRef = storageRef.child(getUid()).child("public").child("images")
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        contentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        if contentTextView.text == "" && contentImageView.image == nil {
            return
        }
        var postContents = [String: Any]()
        postContents["sender"] = getUid()
        postContents["content"] = contentTextView.text
        if !isUserPosts {
            postContents["date"] = FIRServerValue.timestamp()
        }
        if let image = contentImageView.image {
            configureUI(enabled: false)
            Utils.uploadImage(image: image, toReference: imageStorageRef, completionHandler: {(url) in
                if url != nil {
                    postContents["imageUrl"] = url!
                }
                self.uploadPost(contents: postContents)
            })
        } else {
            self.uploadPost(contents: postContents)
        }
    }
    
    func uploadPost(contents: [String: Any]) {
        if isUserPosts {
            let pushPostRef = postsRef.childByAutoId()
            pushPostRef.setValue(contents)
            postLinksRef.child(pushPostRef.key).setValue(FIRServerValue.timestamp())
        } else {
            postsRef.childByAutoId().setValue(contents)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        chooseImage(with: .photoLibrary)
    }
    
    @IBAction func takeImage(_ sender: UIBarButtonItem) {
        chooseImage(with: .camera)
    }
    
    @IBAction func clearImage(_ sender: UIBarButtonItem) {
        contentImageView.image = nil
        clearImageButton.isEnabled = false
        contentImageHeight.constant = 0
    }
    
    func chooseImage(with sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            contentImageView.image = image
            clearImageButton.isEnabled = true
            contentImageHeight.constant = 100
        }
        dismiss(animated: true, completion: nil)
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
        toolbarBottomSpace.constant = -getKeyboardOffset(notification: notification)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        toolbarBottomSpace.constant = 0
    }
    
    private func getKeyboardOffset(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func configureUI(enabled: Bool) {
        contentTextView.isEditable = enabled
        contentTextView.isSelectable = enabled
        contentTextView.isScrollEnabled = enabled
        postButton.isEnabled = enabled
        photoAlbumButton.isEnabled = enabled
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = enabled
        } else {
            cameraButton.isEnabled = false
        }
        if contentImageView.image != nil {
            clearImageButton.isEnabled = enabled
        } else {
            clearImageButton.isEnabled = false
        }
    }
    
}
