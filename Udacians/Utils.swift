//
//  Utils.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/24/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import UIKit
import FirebaseStorage

class Utils {
    
    class func uploadImage(image: UIImage, toReference ref: FIRStorageReference, completionHandler: @escaping (_ url: String?) -> Void) {
        // unique file name, string representation of current Unix time
        let fileName = String(Int(Date().timeIntervalSince1970)) + ".jpg"
        let imageRef = ref.child(fileName)
        // create JPEG with 50% compression
        let imageJpeg = UIImageJPEGRepresentation(image, 0.5)!
        // specify the image format
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        imageRef.put(imageJpeg, metadata: metaData) {metaData, error in
            print(error?.localizedDescription)
            if let url = metaData?.downloadURL()?.absoluteString {
                completionHandler(url)
            } else {
                completionHandler(nil)
            }
        }
    }
    
}
