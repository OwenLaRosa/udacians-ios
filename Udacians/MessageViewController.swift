//
//  MessageViewController.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/13/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class MessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var textEntry: UITextView!
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    // constraint for the preview image view's height
    @IBOutlet weak var imagePreviewHeight: NSLayoutConstraint!
    // height of the text content
    @IBOutlet weak var textEntryHeight: NSLayoutConstraint!
    // starting height of the text view
    // this also serves to calculate the minimum allowed height when resizing
    var defaultTextEntryHeight: CGFloat = 0
    // space root stack view is located from the bottom
    // modified when the keyboard is shown/hidden
    @IBOutlet weak var rootStackViewBottomSpace: NSLayoutConstraint!
    // initial constant value of root stack view bottom space constraint
    var defaultRootBottomSpace: CGFloat = 0
    
    var ref: FIRDatabaseReference!
    var messagesReference: FIRDatabaseReference!
    var senderDirectMessageReference: FIRDatabaseReference!
    var recipientDirectMessageReference: FIRDatabaseReference!
    
    var storageRef: FIRStorageReference!
    
    var messages = [Message]()
    
    var isDirect = false
    var chatId = ""
    var hasJoinedChat = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textEntry.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        ref = FIRDatabase.database().reference()
        storageRef = FIRStorage.storage().reference()
        
        var chatTitleReference: FIRDatabaseReference
        if isDirect {
            messagesReference = getDirectChatReference(user1: getUid(), user2: chatId)
            senderDirectMessageReference = ref.child("users").child(getUid()).child("direct_messages").child(chatId)
            recipientDirectMessageReference = ref.child("users").child(chatId).child("direct_messages").child(getUid())
            chatTitleReference = ref.child("users").child(chatId).child("basic").child("name")
        } else {
            messagesReference = ref.child("topics").child(chatId).child("messages")
            if chatId.hasPrefix("nd") && !chatId.hasSuffix("beta") {
                // course discussion for nanodegree
                chatTitleReference = ref.child("nano_degrees").child(chatId).child("name")
            } else if chatId.hasSuffix("beta") {
                // course discussion for beta nanodegree program
                chatTitleReference = ref.child("nano_degrees").child(chatId.replacingOccurrences(of: "beta", with: "")).child("name")
            } else {
                // user posted discussion topic
                chatTitleReference = ref.child("topics").child(chatId).child("info").child("name")
            }
        }
        chatTitleReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let title = snapshot.value as? String {
                self.title = title
            } else {
                self.title = "Course Discussion"
            }
        })
        messagesReference.queryLimited(toLast: 20).observe(.childAdded, with: {(snapshot) in
            if let messageData = snapshot.value as? [String: Any] {
                self.messages.append(Message(id: snapshot.key, data: messageData))
                self.tableView.reloadData()
                // should automatically move to new messages
                // referenced: http://stackoverflow.com/questions/38044691/scroll-table-view-to-bottom-when-using-dynamic-cell-height/38047639
                self.scrollToBottom()
            }
        })
        
        let tableViewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableViewTap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tableViewTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        defaultTextEntryHeight = textEntry.contentSize.height
        defaultRootBottomSpace = rootStackViewBottomSpace.constant
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        // TODO: allow empty messages if there's an image
        if textEntry.text == "" && imagePreview.image == nil {
            return
        }
        var messageContents = [String: Any]()
        messageContents["sender"] = getUid()
        messageContents["date"] = FIRServerValue.timestamp()
        messageContents["content"] = textEntry.text
        
        if imagePreview.image != nil {
            let imageContents = imagePreview.image!
            self.clearChatEntry()
            let imagesReference = storageRef.child(getUid()).child("public").child("images")
            Utils.uploadImage(image: imageContents, toReference: imagesReference) { (url) in
                if url != nil {
                    messageContents["imageUrl"] = url!
                    self.messagesReference.childByAutoId().setValue(messageContents)
                    if self.isDirect {
                        self.recipientDirectMessageReference.setValue(FIRServerValue.timestamp())
                        self.senderDirectMessageReference.setValue(FIRServerValue.timestamp())
                    } else if !self.chatId.hasPrefix("nd") {
                        if !self.hasJoinedChat {
                            self.hasJoinedChat = true
                            self.ref.child("users").child(self.getUid()).child("topics").child(self.chatId).setValue(true)
                        }
                    }
                }
            }
        } else {
            self.clearChatEntry()
            messagesReference.childByAutoId().setValue(messageContents)
            // TODO: direct messages update last sent time
            if isDirect {
                recipientDirectMessageReference.setValue(FIRServerValue.timestamp())
                senderDirectMessageReference.setValue(FIRServerValue.timestamp())
            } else if !chatId.hasPrefix("nd") {
                if !hasJoinedChat {
                    hasJoinedChat = true
                    ref.child("users").child(getUid()).child("topics").child(chatId).setValue(true)
                }
            }
        }
    }
    
    /// Resets text and image contents of chat entry area
    private func clearChatEntry() {
        textEntry.text = ""
        imagePreview.image = nil
        imagePreviewHeight.constant = 0
    }
    
    // keyboard handling
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        rootStackViewBottomSpace.constant = defaultRootBottomSpace + getKeyboardOffset(notification: notification)
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
        rootStackViewBottomSpace.constant = defaultRootBottomSpace
    }
    
    @objc private func dismissKeyboard() {
        textEntry.resignFirstResponder()
    }
    
    /// Determine how far to move the view based on hgiehgt of keyboard and tab bar
    private func getKeyboardOffset(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height - (tabBarController?.tabBar.frame.height)!
    }
    
    // MARK: - Helpers for messages
    
    /// Get the location of messages for a private chat
    private func getDirectChatReference(user1: String, user2: String) -> FIRDatabaseReference {
        let chatReference: FIRDatabaseReference
        let directMessagesReference = ref.child("direct_messages")
        let user1Int = Int(user1)!
        let user2Int = Int(user2)!
        if user1Int < user2Int {
            chatReference = directMessagesReference.child(user1).child(user2)
        } else {
            chatReference = directMessagesReference.child(user2).child(user1)
        }
        return chatReference
     }
    
    // helpers for table view
    
    func scrollToBottom() {
        if messages.count == 0 { return }
        let lastItem = IndexPath(item: messages.count - 1, section: 0)
        tableView.scrollToRow(at: lastItem, at: .bottom, animated: false)
    }
    
}

extension MessageViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let maxHeight: CGFloat = 100
        let contentSize = textEntry.contentSize
        if contentSize.height < defaultTextEntryHeight {
            textEntryHeight.constant = contentSize.height
        } else if contentSize.height > maxHeight {
            textEntryHeight.constant = maxHeight
        } else {
            textEntryHeight.constant = contentSize.height
        }
    }
    
}

extension MessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // navigation controller delegate is also required for image picker controller delegate
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // if only the image picker is available and there's no image to be removed, go right to the image picker
        if !UIImagePickerController.isSourceTypeAvailable(.camera) && imagePreview.image == nil {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            return
        }
        // otherwise, display an alert with options for photo library, camera (if available), and removing the current image (if applicable)
        let imagePickingAlert = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)
        imagePickingAlert.title = "Choose image"
        imagePickingAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickingAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(alertAction) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        if imagePreview.image != nil {
            imagePickingAlert.addAction(UIAlertAction(title: "Remove Image", style: .default, handler: {(alertAction) in
                self.imagePreview.image = nil
                self.imagePreviewHeight.constant = 0
            }))
        }
        imagePickingAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(imagePickingAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePreviewHeight.constant = 100
            imagePreview.image = image
        }
        dismiss(animated: true, completion: {
            self.scrollToBottom()
        })
    }
    
}

extension MessageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        var cell: PostTableViewCell
        if message.imageUrl == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! PostTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MessageWithImageTableViewCell") as! PostWithImageTableViewCell
        }
        
        let nameReference = ref.child("users").child(message.sender).child("basic").child("name")
        nameReference.observeSingleEvent(of: .value, with: {(snapshot) in
            cell.nameLabel.text = snapshot.value as? String ?? ""
        })
        // users should see their own name in a different color
        if message.sender == getUid() {
            cell.nameLabel.textColor = AppDelegate.accentColor
        } else {
            cell.nameLabel.textColor = AppDelegate.udaciansColorDark
        }
        let photoReference = ref.child("users").child(message.sender).child("basic").child("photo")
        photoReference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let storedImage = WebImageCache.shared.image(with: message.sender) {
                cell.profileImageButton.setImage(storedImage, for: .normal)
            } else {
                if let url = snapshot.value as? String {
                    cell.profileImageTask = WebImageCache.shared.downloadImage(at: url) {imageData in
                        WebImageCache.shared.storeImage(image: imageData, withIdentifier: message.sender)
                        DispatchQueue.main.async {
                            cell.profileImageButton.setImage(imageData, for: .normal)
                            cell.setNeedsLayout()
                        }
                    }
                } else {
                    cell.profileImageButton.setImage(UIImage(named: "Udacians_logo"), for: .normal)
                }
            }
        })
        cell.contentLabel.text = Utils.filterProfanity(from: message.content)
        if message.imageUrl != nil {
            (cell as! PostWithImageTableViewCell).contentImageView.image = nil
            if let storedImage = WebImageCache.shared.image(with: message.id) {
                (cell as! PostWithImageTableViewCell).contentImageView.image = storedImage
                cell.setNeedsLayout()
            } else {
                (cell as! PostWithImageTableViewCell).contentImageTask = WebImageCache.shared.downloadImage(at: message.imageUrl) {imageData in
                    WebImageCache.shared.storeImage(image: imageData, withIdentifier: message.id)
                    DispatchQueue.main.async {
                        (cell as! PostWithImageTableViewCell).contentImageView.image = imageData
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        cell.profileButtonCallback = {
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            profileVC.thisUser = message.sender
            self.show(profileVC, sender: nil)
        }
        
        return cell
    }
    
}
