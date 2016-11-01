//
//  UdacityClient.swift
//  Udacians
//
//  Created by Owen LaRosa on 10/29/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import Foundation

public class UdacityClient {
    
    // global instance to use this class as a singleton
    public static var shared = UdacityClient()
    
    /// Request token used to authenticate with Firebase
    public var token = ""
    
    // endpoint for session method
    private let URL_SESSION = "http://localhost:8080/_ah/api/myApi/v1/session"
    
    // request parameter keys
    private let PARAM_EMAIL = "username"
    private let PARAM_PASSWORD = "password"
    
    // JSON parsing keys
    private let KEY_CODE = "code"
    private let KEY_TOKEN = "token"
    
    /// Get an authentication token with the given email and password
    public func getToken(email: String, password: String, completionHandler: @escaping (_ success: Bool, _ code: Int) -> Void) -> URLSessionTask {
        // global url session instance
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: URL_SESSION)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"username\": \"\(email)\", \"password\": \"\(password)\"}".data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request) {data, response, error in
            if error != nil {
                completionHandler(false, (response as? HTTPURLResponse)?.statusCode ?? 0)
            } else {
                let jsonObject = JSON(data: data!)
                let code = jsonObject[self.KEY_CODE].intValue
                if code == 200 {
                    // save the token and alert the caller if successful
                    self.token = jsonObject[self.KEY_TOKEN].stringValue
                    completionHandler(true, code)
                } else {
                    // alert the caller of an error
                    // currently, specific errors are not returned by the server, so use empty string for now
                    completionHandler(false, code)
                }
            }
        }
        task.resume()
        
        return task
    }
    
    
}
