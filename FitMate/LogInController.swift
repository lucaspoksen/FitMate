//
//  LogInController.swift
//  FitMate
//
//  Created by PSIHPOK on 11/19/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKCoreKit
import FBSDKLoginKit

class LogInController: UIViewController {
    
    @IBOutlet weak var m_LoadingActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var m_StatusLabel: UILabel!
    
    @IBOutlet weak var m_FBLoginButton: UIButton!
    
    @IBOutlet weak var m_AgreeSwitch: UISwitch!
    
    @IBOutlet weak var m_MustLocationAlertView: UIView!
    
    @IBOutlet weak var m_AgreeLabel: UILabel!
    
    @IBOutlet weak var m_AgreeButton: UIButton!
    
    var m_Timer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        //initial view
        m_AgreeSwitch.on = false
        m_FBLoginButton.hidden = true
        m_StatusLabel.hidden = true

        //FBToken Check
        addFBTokenChangeObserver()
        //LocationAccess Check
        beReadyForCheckLocation()
    }
    
    func addFBTokenChangeObserver(){
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "profileUpdated:", name: FBSDKAccessTokenDidChangeNotification, object: nil)
    }
    
    func checkLocationEnabled(){
        var bEnabled:Bool = true
        let locationEnabled = CLLocationManager.locationServicesEnabled()
        
        if locationEnabled == false
        {
            bEnabled = false
            m_Timer.invalidate()
            showNecessaryItems(bEnabled)
        }
        
        if (FitMateLocationManager.sharedInstance.currentStatus == CLAuthorizationStatus.Denied){
            FitMateLocationManager.sharedInstance.stopTimer()
            bEnabled = false
            m_Timer.invalidate()
            showNecessaryItems(bEnabled)
        }
        else if (FitMateLocationManager.sharedInstance.currentStatus == CLAuthorizationStatus.AuthorizedWhenInUse){
            m_Timer.invalidate()
            showNecessaryItems(bEnabled)
        }
    }
   
    func beReadyForCheckLocation(){
        hideAllItems()
        m_LoadingActivity.hidden = false
        m_LoadingActivity.startAnimating()
        m_Timer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "checkLocationEnabled", userInfo: nil, repeats: true)
    }
    
    func showNecessaryItems(bLocationEnabled:Bool){
        m_LoadingActivity.stopAnimating()
        m_LoadingActivity.hidden = true
        
        let bFirstUse = checkFirstUse()
        
        if (bFirstUse == true){
            self.m_AgreeSwitch.hidden = !bLocationEnabled
            self.m_AgreeLabel.hidden = !bLocationEnabled
            self.m_AgreeButton.hidden = !bLocationEnabled
            self.m_MustLocationAlertView.hidden = bLocationEnabled
        }
        else {
            if (bLocationEnabled == false){
                m_AgreeSwitch.hidden = !bLocationEnabled
                m_AgreeLabel.hidden = !bLocationEnabled
                m_AgreeButton.hidden = !bLocationEnabled
                m_MustLocationAlertView.hidden = bLocationEnabled
            }
            else {
                goActivitySettingController()
//                goMainController()
            }
        }
    }
    
    func hideAllItems(){
        m_AgreeSwitch.hidden = true
        m_AgreeLabel.hidden = true
        m_AgreeButton.hidden = true
        m_MustLocationAlertView.hidden = true
    }
    
    func makeUnderlineLabel(textLabel:UILabel){
        let string:NSMutableAttributedString = NSMutableAttributedString(string: "You agree to our terms of service.")
        string.addAttribute(NSFontAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, string.length))
        let underlineNumber:NSNumber = NSNumber(long: 1)
        
        string.addAttribute(NSForegroundColorAttributeName, value: underlineNumber, range: NSMakeRange(0, string.length))
        string.addAttribute(NSUnderlineStyleAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, string.length))
        textLabel.attributedText = string
    }
    
    func checkFirstUse() -> Bool
    {

        
        if(NSUserDefaults.standardUserDefaults().boolForKey("newLogin") == true) {
            print("newLogin is true")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "newLogin")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ReadyForUse")
            return true
        }
        else if (FBSDKAccessToken.currentAccessToken() == nil) {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ReadyForUse")
            return true
        }
        return false
    }
    
    func checkFirstLaunch() ->Bool{
        if NSUserDefaults.standardUserDefaults().valueForKey("FirstLaunch") != nil {
            if NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch") == true {
                return true
            }
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onAcceptTerms(sender: AnyObject) {
        let bAccept = (sender as! UISwitch).on
        if bAccept == true{
            confirmAlert()
        }
        else {
            acceptTerms(false)
        }
    }
    
    @IBAction func onClickFBLogin(sender: AnyObject) {
        let login:FBSDKLoginManager = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email", "user_birthday"], handler:nil)
    }
    
    func acceptTerms(bAccept: Bool){
        let bHidden = !bAccept
        m_FBLoginButton.hidden = bHidden
        m_StatusLabel.hidden = bHidden
        NSUserDefaults.standardUserDefaults().setBool(bAccept, forKey: "TermsAccepted")
    }
    
    func confirmAlert(){
        let alertView: UIAlertController = UIAlertController(title: "Confirm Agreement", message: "Do you agree to our Terms of Service?", preferredStyle: .Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (action: UIAlertAction) in
                self.acceptTerms(true)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
            (action: UIAlertAction) in
                self.m_AgreeSwitch.on = false
                self.acceptTerms(false)
        })
        
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func onClickTermsService(sender: AnyObject) {
        goToTermsServiceHelp()
    }
    
    func goToTermsServiceHelp(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let termsController = storyboard.instantiateViewControllerWithIdentifier("TermsOfServiceController") as! UINavigationController
        let mainController = termsController.topViewController as! TermsOfServiceController
        mainController.m_AboutUs = false
        self.presentViewController(termsController, animated: true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func profileUpdated(notification: NSNotification) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            if ProfileManager.sharedInstance.fbServerRequest() {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ReadyForUse")
                //Wait Complete Loading Profile
                hideAllItems()
                m_FBLoginButton.hidden = true
                m_StatusLabel.hidden = true
                m_LoadingActivity.hidden = false
                m_LoadingActivity.hidesWhenStopped = true
                m_LoadingActivity.startAnimating()
                m_Timer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "waitCompleteLoadingProfile", userInfo: nil, repeats: true)
                
                //Go to Activity Controller
//              goActivitySettingController()
            } else {
                //handle facebook connection error
                print("Error connecting to facebook server API.")
            }
        }
    }
    
    func waitCompleteLoadingProfile(){
        let bLoadComplete = ProfileManager.sharedInstance.bLoadUserProfileComplete
        if (bLoadComplete == true){
            m_Timer.invalidate()
            m_LoadingActivity!.stopAnimating()
            goActivitySettingController()
        }
    }
    
    func goActivitySettingController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let activityNavController:UINavigationController! = storyboard.instantiateViewControllerWithIdentifier("SaveActivityController") as! UINavigationController
        
        let activitySettingController:ActivitySettingController! = activityNavController.topViewController as! ActivitySettingController
        activitySettingController.m_FromWhere = BearActivityControllerType.FW_FIRSTUSE
        
        self.presentViewController(activityNavController, animated: true, completion: nil)
    }
    
    func goMainController(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let activityNavController:FitMateTabBarController! = storyboard.instantiateViewControllerWithIdentifier("FitMateTabBarController") as! FitMateTabBarController
        self.presentViewController(activityNavController, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.LightContent
    }
}