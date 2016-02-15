//
//  SettingController.swift
//  FitMate
//
//  Created by PSIHPOK on 12/5/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class SettingController:UIViewController{
    
    @IBOutlet weak var m_PhotoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_PhotoImage!.sd_setImageWithURL(NSURL(string: ProfileManager.sharedInstance.userProfile.photo), placeholderImage: UIImage(named: "unknown_photo"))
    }
    
    @IBAction func onClickDetail(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailNavController: UINavigationController = storyboard.instantiateViewControllerWithIdentifier("ProfileDetailController") as! UINavigationController
        let detailController:ProfileDetailController = detailNavController.topViewController as! ProfileDetailController
        
        detailController.showUserProfile = true
        self.presentViewController(detailNavController, animated: true, completion: nil)
    }
    
    @IBAction func onClickAboutUs(sender: AnyObject) {
        goAboutOrTermScreen(true)
    }
    
    @IBAction func onClickTermsService(sender: AnyObject) {
        goAboutOrTermScreen(false)
    }
    
    @IBAction func onClickBlockList(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let blockController = storyboard.instantiateViewControllerWithIdentifier("BlockListController")
        self.presentViewController(blockController, animated: true, completion: nil)
    }
    
    @IBAction func onClickDeleteAccount(sender: AnyObject) {
        let deleteAlert: UIAlertController = UIAlertController(title: "Really delete your account?", message: nil, preferredStyle: .Alert)
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .Destructive) { (let action) -> Void in
            //delete the account
            ProfileManager.sharedInstance.deleteAccount()
            //let loginManager = FBSDKLoginManager()
            //loginManager.logOut()
            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                //(UIApplication.sharedApplication().delegate! as! AppDelegate).showSigninScreen()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        self.presentViewController(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goAboutOrTermScreen(bAboutUs: Bool){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let termsController = storyboard.instantiateViewControllerWithIdentifier("TermsOfServiceController") as! UINavigationController
        let mainController = termsController.topViewController as! TermsOfServiceController
        mainController.m_AboutUs = bAboutUs
        self.presentViewController(termsController, animated: true, completion: nil)
    }
}
