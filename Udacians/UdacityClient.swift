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
    private let URL_SESSION = "https://udacians-df696.appspot.com/_ah/api/myApi/v1/session"
    // endpoint for direct udacity login
    private let URL_LOGIN = "https://www.udacity.com/api/session"
    // endpoint for getting public user data
    private let URL_USER = "https://www.udacity.com/api/users/"
    
    // request parameter keys
    private let PARAM_EMAIL = "username"
    private let PARAM_PASSWORD = "password"
    
    // JSON parsing keys
    private let KEY_CODE = "code"
    private let KEY_TOKEN = "token"
    
    /// Get an authentication token with the given email and password
    public func getToken(email: String, password: String, completionHandler: @escaping (_ success: Bool, _ code: Int) -> Void)  {
        // verify the login and get cookies
        _ = getXSRFToken(email: email, password: password, completionHandler: { success, code in
            if success {
                // login through the server to get auth token
                let session = URLSession.shared
                var request = URLRequest(url: URL(string: self.URL_SESSION)!)
                request.httpMethod = "POST"
                request.httpBody = "username=\(email)&password=\(password)".data(using: String.Encoding.utf8)
                let task = session.dataTask(with: request) {data, response, error in
                    if error != nil {
                        completionHandler(false, (response as? HTTPURLResponse)?.statusCode ?? 0)
                    } else {
                        let jsonObject = JSON(data: data!)
                        print(jsonObject)
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
            }
        }).resume()
    }
    
    /// In order to get full user data, we need the proper cookies
    /// These can be obtained by logging in directly from the client
    public func getXSRFToken(email: String, password: String, completionHandler: @escaping (_ success: Bool, _ code: Int) -> Void) -> URLSessionTask {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: URL_LOGIN)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request) {data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            print("first login response: \(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))")
            if statusCode == 200 {
                completionHandler(true, 200)
            } else {
                completionHandler(false, statusCode)
            }
        }
        task.resume()
        
        return task
    }
    
    public func getDataForUserId(userId: String, completionHandler: @escaping (_ user: User?, _ code: Int) -> Void) -> URLSessionTask {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: "\(URL_USER)\(userId)")!)
        request.httpMethod = "GET"
        print("user id: \(userId)")
        let task = session.dataTask(with: request) {data, response, error in
            if error != nil {
                completionHandler(nil, (response as? HTTPURLResponse)?.statusCode ?? 0)
            } else {
                // responses from Udacity API must be trimmed
                let newData = data!.subdata(in: 5..<data!.count)
                let jsonObject = JSON(data: newData)
                let firstName = jsonObject["user"]["first_name"].stringValue
                let lastName = jsonObject["user"]["last_name"].stringValue
                let user = User(userId: userId, firstName: firstName, lastName: lastName)
                
                let enrollments = jsonObject["user"]["_enrollments"].arrayValue
                // enrollments that have their own group chat
                var valid = [String]()
                for i in enrollments {
                    // only include Nanodegree courses
                    if i["node_key"].stringValue.hasPrefix("nd") {
                        valid.append(i["node_key"].stringValue)
                    }
                }
                let profile = Profile(enrollments: valid)
                user.profile = profile
                completionHandler(user, 200)
            }
        }
        task.resume()
        
        return task
    }
    
    
}
