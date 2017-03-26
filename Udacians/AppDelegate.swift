//
//  AppDelegate.swift
//  Udacians
//
//  Created by Owen LaRosa on 10/27/16.
//  Copyright © 2016 Owen LaRosa. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // connect to firebase on startup
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        // set up Google Maps
        //GMSServices.provideAPIKey("AIzaSyDd4YX1xiy9u0uHcloSlmefAiv2svg1WFo")
        GMSServices.provideAPIKey("AIzaSyCwxxASjGvziAJ5lm7x0OkVwbpXJW5HPyc")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        // the authentication process takes time, so we need a dummy VC to stand in for the launch screen
        // this ensures there isn't an awkward black screen inbetweem the launcher and presented VC
        let placeholderVC = UIViewController()
        placeholderVC.view.frame = UIScreen.main.bounds
        placeholderVC.view.backgroundColor = UIColor.white
        window?.rootViewController = placeholderVC
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // user has logged in from a previous session
        if let token = UserDefaults.standard.string(forKey: "token") {
            FIRAuth.auth()?.signIn(withCustomToken: token, completion: {user, error in
                if let _ = user?.uid {
                    // successfully logged in, proceed to main navigation
                    let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                    self.window?.rootViewController = mainVC
                } else {
                    // authentication token expired
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    self.window?.rootViewController = loginVC
                }
            })
        } else {
            // no login from previous session
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.window?.rootViewController = loginVC
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

