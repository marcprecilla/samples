//
//  ViewController.swift
//  SwiftBeacon
//
//  Created by Christopher Perry on 11/1/15.
//  Copyright © 2015 thefancywizard. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneSubmitButton: UIButton!
    
    var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.phoneTextField.keyboardType = UIKeyboardType.PhonePad
        self.phoneTextField.returnKeyType = UIReturnKeyType.Done
        
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
        
    //    Alamofire.request(.GET, "http://sms.as2.guidance.com/beaconsms/beacon-uuid").responseString { response in
     //       self.setUuid(response.result.value!)
     //   }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //check to see if phone and pin are already stored
        var phone = ""
        var pin = ""
        if (NSUserDefaults.standardUserDefaults().objectForKey("phone") != nil) {
            phone = NSUserDefaults.standardUserDefaults().objectForKey("phone") as! String
        }
        if (NSUserDefaults.standardUserDefaults().objectForKey("pin") != nil) {
            pin = NSUserDefaults.standardUserDefaults().objectForKey("pin") as! String
        }
        
        if(phone != "" && pin != "") {
            print("phone:" + phone);
            print("pin:" + pin);
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("ListenerViewController")
            self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
        }
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer!.frame = self.view.bounds;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        phoneTextField.resignFirstResponder()
        return true;
    }
    
    func alertOKHandler(alert: UIAlertAction!) {
        //let vc = TwoViewController(nibName: "PinViewController", bundle: nil)
        //presentViewController(vc, animated: true, completion: nil)
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("PinViewController")
        self.showViewController(vc as! UIViewController, sender: vc)

    }

    @IBAction func phoneNumberSubmitted(sender: UIButton) {
        phoneTextField.resignFirstResponder()
        
        let phoneNumber:String = String(self.phoneTextField.text!)
        
        NSUserDefaults.standardUserDefaults().setObject(phoneNumber, forKey: "phone")
        
        let request_url = "http://sms.as2.guidance.com/beaconsms/getpin/\(phoneNumber)/1/1"
        //let request_url = "http://www.marcprecilla.com/beaconsms/number.json"
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

    
    
   
    

}

