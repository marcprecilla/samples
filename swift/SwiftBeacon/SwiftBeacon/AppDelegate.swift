//
//  AppDelegate.swift
//  SwiftBeacon
//
//  Created by Christopher Perry on 11/1/15.
//  Copyright © 2015 thefancywizard. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RPKManagerDelegate {
    
    var window: UIWindow?
    
    
    var proximityKitManager: RPKManager?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /*
        self.proximityKitManager = RPKManager(delegate: self)
        self.proximityKitManager!.start()
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        */

        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /*
    
    func proximityKitDidSync(manager : RPKManager) {
        NSLog("didSync")
    }
    
    func proximityKit(manager: RPKManager!, didDetermineState state: RPKRegionState, forRegion region: RPKRegion!) {
        NSLog("didDetermineState \(state) for region \(region)")
    //    let beaconUuid = "123"
   //     let userPhoneNumber = "9493109388"
     //   Alamofire.request(.GET, "http://sms.as2.guidance.com/beaconsms/\(beaconUuid)/\(userPhoneNumber)/xxxf")
     //   NSLog("http://sms.as2.guidance.com/beaconsms/\(beaconUuid)/\(userPhoneNumber)/xxxf")
    }
    
    func proximityKit(manager : RPKManager, didEnter region:RPKRegion) {
        NSLog("didEnter region %@", region)
    }
    
    func proximityKit(manager : RPKManager, didExit region:RPKRegion) {
        NSLog("didExit region %@", region)
    }
    */
    

}


