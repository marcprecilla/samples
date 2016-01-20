//
//  PinViewController.swift
//  SwiftBeacon
//
//  Created by Marc on 11/25/15.
//  Copyright © 2015 thefancywizard. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class PinViewController: UIViewController {

    var gradientLayer: CAGradientLayer?
    
    func alertOKHandler(alert: UIAlertAction!) {
        //let vc = TwoViewController(nibName: "ListenerViewController", bundle: nil)
        //presentViewController(vc, animated: true, completion: nil)
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("ListenerViewController")
        self.showViewController(vc as! UIViewController, sender: vc)
    }
    @IBOutlet weak var pinTextField: UITextField!
    
    @IBAction func pinSubmitButton(sender: UIButton) {
        
        let pinNumber:String = String(self.pinTextField.text!)
        
        var phone = ""
        if (NSUserDefaults.standardUserDefaults().objectForKey("phone") != nil) {
            phone = NSUserDefaults.standardUserDefaults().objectForKey("phone") as! String
        }
        
        let request_url = "http://sms.as2.guidance.com/beaconsms/confirmpin/\(phone)/\(pinNumber)"
        //let request_url = "http://www.marcprecilla.com/beaconsms/pin.json"
        //NSLog(request_url)
        Alamofire.request(.GET, request_url)
            .responseJSON { response in
                //debugPrint(response)
                
                var transaction_success = false
                var transaction_message = ""
                var defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                guard response.result.error == nil else {
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
                    if let success = json["success"].int {
                        transaction_success = (success == 1)
                        if (transaction_success) {
                            NSUserDefaults.standardUserDefaults().setObject(pinNumber, forKey: "pin")
                            
                            if let data_message = json["message"].string {
                                transaction_message = data_message
                                defaultAction = UIAlertAction(title: "OK", style: .Default, handler: self.alertOKHandler)
                            }
                        } else {
                            if let data_message = json["message"].string {
                                transaction_message = data_message
                            }
                        }
                    } else {
                        transaction_message = ("error with json")
                    }
                    
                    let alertController = UIAlertController(title: "Thank You", message: transaction_message, preferredStyle: .Alert)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    
                }
                
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    
}
