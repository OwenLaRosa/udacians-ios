//
//  WebImageCache.swift
//  Udacians
//
//  Created by Owen LaRosa on 2/9/17.
//  Copyright © 2017 Owen LaRosa. All rights reserved.
//

import Foundation
import UIKit

// Image cache based on the code from Jason @ Udacity
class WebImageCache {
    
    public static var shared = WebImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    public func downloadImage(at path: String, completionHandler: @escaping (_ imageData: UIImage?) -> Void) -> URLSessionDataTask {
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) {data, response, error in
            if data != nil {
                completionHandler(UIImage(data: data!))
            } else {
                completionHandler(nil)
            }
        }
        task.resume()
        
        return task
    }
    
    public func image(with identifier: String) -> UIImage? {
        let path = pathFor(identifier: identifier)
        // first try to get image from cache
        if let image = cache.object(forKey: path as NSString) as UIImage! {
            return image
        }
        // otherwise check the file system
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data as Data)!
        }
        // image does not exist
        return nil
    }
    
    public func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathFor(identifier: identifier)
        
        // delete image with identifier if the image is nil
        if image == nil {
            cache.removeObject(forKey: path as NSString)
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch _ {}
            return
        }
        
        // image should be stored in cache and in documents directory
        cache.setObject(image!, forKey: path as NSString)
        let data = UIImagePNGRepresentation(image!)!
        try? data.write(to: URL(string: path)!)
    }
    
    private func pathFor(identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        return "\(documentsDirectoryURL.path)/\(identifier)"
    }
    
}
