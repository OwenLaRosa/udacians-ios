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
    
    static var bannedWords = [String]()
    
    class func uploadImage(image: UIImage, toReference ref: FIRStorageReference, completionHandler: @escaping (_ url: String?) -> Void) {
        DispatchQueue.global(qos: .background).async {
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
                DispatchQueue.main.async {
                    if let url = metaData?.downloadURL()?.absoluteString {
                        completionHandler(url)
                    } else {
                        completionHandler(nil)
                    }
                }
            }
        }
    }
    
    /// Determine if a URL is valid with or without prefixing http://
    /// Many users leave out this prefix so function attempts to "fix" the url
    /// if invalid in either case, return nil
    class func validateUrl(url: String) -> String? {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let _ = url.range(of: pattern, options: .regularExpression) {
            return url
        } else if let _ = ("http://" + url).range(of: pattern, options: .regularExpression) {
            return "http://" + url
        }
        return nil
    }
    
    class func filterProfanity(from text: String) -> String {
        var stringToFilter = text;
        let replacement = "******"
        for word in Utils.bannedWords {
            if stringToFilter.characters.count == word.characters.count && stringToFilter.lowercased() == word.lowercased() {
                return replacement
            }
            while let range = stringToFilter.range(of: word, options: .caseInsensitive, range: nil, locale: nil) {
                if range.lowerBound != stringToFilter.startIndex {
                    if !String(describing: CharacterSet.letters).contains(String(stringToFilter.characters[stringToFilter.index(before: range.lowerBound)])) {
                        stringToFilter = stringToFilter.replacingCharacters(in: range, with: replacement)
                        continue
                    }
                } else {
                    stringToFilter = stringToFilter.replacingCharacters(in: range, with: replacement)
                }
                if range.upperBound != stringToFilter.endIndex {
                    if !String(describing: CharacterSet.letters).contains(String(stringToFilter.characters[stringToFilter.index(after: range.upperBound)])) {
                        stringToFilter = stringToFilter.replacingCharacters(in: range, with: replacement)
                        continue
                    }
                } else {
                    stringToFilter = stringToFilter.replacingCharacters(in: range, with: replacement)
                }
            }
        }
        return stringToFilter
    }
    
}
