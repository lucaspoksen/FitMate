//
//  FitMateLocationManager.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/5/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

import Foundation
import CoreLocation
import FBSDKCoreKit
import FBSDKLoginKit

class FitMateLocationManager:NSObject, CLLocationManagerDelegate {
    static let sharedInstance = FitMateLocationManager()
    
    var manager: CLLocationManager = CLLocationManager()
    var lastLocation: CLLocationCoordinate2D?
    var haveLocation = false
    var timer: NSTimer?
    var oldStatus:CLAuthorizationStatus?
    var currentStatus:CLAuthorizationStatus?
    var bFirstLaunch:Bool = true
    
    func start() {
        self.manager.delegate = self
        self.oldStatus = CLLocationManager.authorizationStatus()
        if self.oldStatus == .NotDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.0, target: self, selector: "checkStatus", userInfo: nil, repeats: true)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        currentStatus = status
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == .AuthorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
        
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == .AuthorizedWhenInUse || status == .Denied){
            if (bFirstLaunch == true){
                bFirstLaunch = false
            }
            else {
                
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ReadyForUse")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "newLogin")
                (UIApplication.sharedApplication().delegate! as! AppDelegate).showSignInScreen()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations[0].coordinate
        haveLocation = true
    }
    
    func checkStatus()
    {
        currentStatus = CLLocationManager.authorizationStatus()
        if (currentStatus == .AuthorizedWhenInUse || currentStatus == .Denied){
            stopTimer()
        }
    }
    
    func stopTimer()
    {
        if (self.timer?.valid == true){
            self.timer?.invalidate()
        }
    }
}

