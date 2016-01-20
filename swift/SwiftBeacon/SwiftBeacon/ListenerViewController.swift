//
//  ListenerViewController.swift
//  SwiftBeacon
//
//  Created by Marc on 11/25/15.
//  Copyright © 2015 thefancywizard. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class BeaconData: NSObject {
    var id: String
    var distance: Int
    var proximity: Int
    init(id: String, distance: Int, proximity: Int) {
        self.id = id
        self.distance = distance
        self.proximity = proximity
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = (aDecoder.decodeObjectForKey("id") as? String)!
        self.distance = aDecoder.decodeIntegerForKey("distance")
        self.proximity = aDecoder.decodeIntegerForKey("proximity")
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(distance, forKey: "distance")
        aCoder.encodeObject(proximity, forKey: "proximity")
    }
    
    override  var description: String {
        return "BeaconData: \(id) \(distance) \(proximity)"
    }
}

class ListenerViewController: UIViewController, CLLocationManagerDelegate {

    var gradientLayer: CAGradientLayer?
    var locationManager = CLLocationManager()
    var region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!, identifier: "Radbeacon USBs")
    var userPhoneNumber = ""
    var userPinNumber = ""

    @IBOutlet weak var beaconStatusLabel: UILabel!
    @IBOutlet weak var rangeButtonOutlet: MyCustomButton!
    @IBAction func rangeButton(sender: UIButton) {
        
        if(self.rangeButtonOutlet.titleLabel!.text == "Start Searching") {
            //NSLog("attempting to start")
            startRanging()
        } else {
            //NSLog("attempting to stop")
            stopRanging()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy  = kCLLocationAccuracyBest
        if #available(iOS 9.0, *) {
            self.locationManager.allowsBackgroundLocationUpdates = true
        }
        
        
        let topColor = UIColor(red:(233/255.0), green: (239/255.0), blue: (190/255.0), alpha: 1)
        let bottomColor = UIColor(red: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 1)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.frame = self.view.bounds
        
        self.gradientLayer = gradientLayer
        self.view.layer.insertSublayer(self.gradientLayer!, atIndex: 0)
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("phone") != nil) {
            self.userPhoneNumber = NSUserDefaults.standardUserDefaults().objectForKey("phone") as! String
        }
        if (NSUserDefaults.standardUserDefaults().objectForKey("pin") != nil) {
            self.userPinNumber = NSUserDefaults.standardUserDefaults().objectForKey("pin") as! String
        }
        
        
        
        
        Alamofire.request(.GET, "http://sms.as2.guidance.com/beaconsms/beaconrange")
            .responseString { response in
                let new_range = Int(response.result.value!)
                if(new_range >= 1) {
                    NSUserDefaults.standardUserDefaults().setObject(new_range, forKey: "range")
                }
        }
        
        //get beacon region
        let request_url = "http://sms.as2.guidance.com/beaconsms/beacon-uuid"
        Alamofire.request(.GET, request_url)
            .responseString { response in
                //debugPrint(response)
                
                self.region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: response.result.value!)!, identifier: "Radbeacon USBs")
                self.region.notifyOnEntry = true;
                self.region.notifyOnExit = true;
                self.region.notifyEntryStateOnDisplay = true;
                self.startRanging()
                
        }
        
        //get and store beacon range data
        let all_beacon_request_url = "http://sms.as2.guidance.com/beaconsms/getallbeacons"
        Alamofire.request(.GET, all_beacon_request_url)
            .responseJSON { response in
                //debugPrint(response)
                
                guard response.result.error == nil else {

                    var transaction_message = ""
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

                    // got an error in getting the data, need to handle it
                    transaction_message = String("An error with the request occurred.")
                    transaction_message += String(response.result.error!)
                    let alertController = UIAlertController(title: "Error", message: transaction_message, preferredStyle: .Alert)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
                
                if let value: AnyObject = response.result.value {
                    // handle the results as JSON, without a bunch of nested if loops
                    let json = JSON(value)
                    //debugPrint(json)
                    let json_data:[JSON] = json.arrayValue
                    var beacon_range_data: NSMutableArray = []
                    for item in json_data {
                        var current_id = ""
                        var current_distance = 1
                        var current_proximity = 1
                        current_id = item["id"].stringValue
                        current_distance = item["distance"].intValue
                        current_proximity = item["proximity"].intValue
                        let current_item = BeaconData(id: current_id,distance: current_distance, proximity: current_proximity)
                        beacon_range_data.addObject(current_item)
                    }
                    
                    let beaconRangeData = NSKeyedArchiver.archivedDataWithRootObject(beacon_range_data)
                    
                    NSUserDefaults.standardUserDefaults().setObject(beaconRangeData, forKey: "beacon_ranges")
                    
                    
                }
                
        }


        

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer!.frame = self.view.bounds;
    }
    
    
    // Note: make sure you replace the keys here with your own beacons' Minor Values
    let colors = [
        8: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        55: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        27327: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]
    
    func startRanging() {
        self.beaconStatusLabel.text = "searching"
        rangeButtonOutlet.setTitle("Stop Searching", forState: .Normal)
        
        self.locationManager.startMonitoringForRegion(self.region)
        //self.locationManager.startRangingBeaconsInRegion(self.region)
        //self.locationManager.startUpdatingLocation()
        
        //print("startRanging")

    }
    
    func stopRanging() {
        self.beaconStatusLabel.text = "paused"
        rangeButtonOutlet.setTitle("Start Searching", forState: .Normal)
        
        self.locationManager.stopMonitoringForRegion(self.region)
        //self.locationManager.stopRangingBeaconsInRegion(self.region)
        self.locationManager.stopUpdatingLocation()
        
        //print("stopRanging")
        
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        self.locationManager.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //print("entered region")
        dispatch_async(dispatch_get_main_queue(), {
            self.beaconStatusLabel.text = "entered CVC space"
        })
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        //print("left region")
        dispatch_async(dispatch_get_main_queue(), {
            self.beaconStatusLabel.text = "left CVC space"
        })
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if state == CLRegionState.Inside {
            self.beaconStatusLabel.text = "searching (active)"
            self.locationManager.startRangingBeaconsInRegion(self.region)
            self.locationManager.startUpdatingLocation()
        }
        else if(state == CLRegionState.Outside) {
            /*
            dispatch_async(dispatch_get_main_queue(), {
                self.beaconStatusLabel.text = "left region"
            })
            */
            self.beaconStatusLabel.text = "searching (lower power mode)"
            self.locationManager.stopRangingBeaconsInRegion(self.region)
            self.locationManager.stopUpdatingLocation()
        } else if(state == CLRegionState.Unknown) {
            self.beaconStatusLabel.text = "lost"
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        //NSLog("searching")
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            
            /*
            var range = 2
            if (NSUserDefaults.standardUserDefaults().objectForKey("range") != nil) {
                range = NSUserDefaults.standardUserDefaults().objectForKey("range") as! Int
            }
            */
            let beaconUuid = "\(closestBeacon.proximityUUID.UUIDString)-\(closestBeacon.minor.integerValue)"
            let targetBeaconData = self.getBeaconData(beaconUuid)
            
            let proximityValue = closestBeacon.proximity.rawValue
            if (proximityValue == targetBeaconData.proximity) {
                
                var used_beacon_ids: [String]
                used_beacon_ids = []

                //reset timer
                let now = NSDate();
                let userCalendar = NSCalendar.currentCalendar()
                if (NSUserDefaults.standardUserDefaults().objectForKey("last_reset_date") != nil) {
                    let last_reset_date = NSUserDefaults.standardUserDefaults().objectForKey("last_reset_date") as! NSDate
                    //print(last_reset_date)
                    
                    if(now.compare(last_reset_date) == NSComparisonResult.OrderedDescending) {
                        //reset
                        NSUserDefaults.standardUserDefaults().setObject(used_beacon_ids, forKey: "used_beacon_ids")
                        let next_reset_date = userCalendar.dateByAddingUnit(
                            [.Minute],
                            value: 1,
                            toDate: NSDate(),
                            options: [])!
                        NSUserDefaults.standardUserDefaults().setObject(next_reset_date, forKey: "last_reset_date")
                    }
                    
                } else {
                    //initialize
                    let next_reset_date = userCalendar.dateByAddingUnit(
                        [.Minute],
                        value: 1,
                        toDate: NSDate(),
                        options: [])!
                    NSUserDefaults.standardUserDefaults().setObject(next_reset_date, forKey: "last_reset_date")
                }
                
                if (NSUserDefaults.standardUserDefaults().objectForKey("used_beacon_ids") != nil) {
                    used_beacon_ids = NSUserDefaults.standardUserDefaults().objectForKey("used_beacon_ids") as! Array
                }
                
                if !used_beacon_ids.contains(beaconUuid) {

                    dispatch_async(dispatch_get_main_queue(), {
                        self.beaconStatusLabel.text = "found new"
                        
                        /*
                        let notification = UILocalNotification()
                        notification.alertBody =
                        "You have found beacon \(beaconUuid)"
                        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                        notification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                        */

                    })

                    //NSLog(beaconUuid + " is close broah!")
                    used_beacon_ids.append(beaconUuid)
                    NSUserDefaults.standardUserDefaults().setObject(used_beacon_ids, forKey: "used_beacon_ids")
                    
                    //Alamofire.request(.GET, "http://sms.as2.guidance.com/beaconsms/\(beaconUuid)/\(self.userPhoneNumber)/xxxf")
                    Alamofire.request(.GET, "http://sms.as2.guidance.com/beaconsms/sendsms/\(self.userPhoneNumber)/\(beaconUuid)/\(self.userPinNumber)")
                    
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.beaconStatusLabel.text = "found old"
                    })

                    //NSLog("same uuid found");
                    //print(used_beacon_ids)
                }
                
                
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    //self.beaconStatusLabel.text = "searching"
                })
                
            }
            
            
        }
    }

    
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({})
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.sharedApplication().endBackgroundTask(taskID)
    }
    
    func getBeaconData(id: String) -> BeaconData {
        var targetBeaconData = BeaconData(id: "1",distance: 1, proximity: 1)
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("beacon_range_data") != nil) {
            let beaconRangeData = NSUserDefaults.standardUserDefaults().objectForKey("beacon_range_data") as? NSData
            if let beaconRangeData = beaconRangeData {
                let beaconRangeArray = NSKeyedUnarchiver.unarchiveObjectWithData(beaconRangeData) as? [BeaconData]
                //debugPrint(beacon_range_data)
                
                if let beaconRangeArray = beaconRangeArray {
                    for item in beaconRangeArray {
                        if (item.id == id) {
                            targetBeaconData = item
                            break
                        }
                    }
                }
            }
        }
        
        return targetBeaconData

    }


}
