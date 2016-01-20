//
//  Buttons.swift
//  SwiftBeacon
//
//  Created by Marc on 11/25/15.
//  Copyright © 2015 thefancywizard. All rights reserved.
//

import Foundation

class MyCustomButton: UIButton {
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = UIColor(red:(102/255.0), green: (45/255.0), blue: (145/255.0), alpha: 1)
        self.tintColor = UIColor.whiteColor()
        
    }
}

