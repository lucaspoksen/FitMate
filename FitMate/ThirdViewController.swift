//
//  ThirdViewController.swift
//  FitMate
//
//  Created by Derek Sanchez on 8/14/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

import UIKit
import QuartzCore
import SDWebImage
import MDCSwipeToChoose
import FBSDKCoreKit
import FBSDKLoginKit
import FontAwesomeKit

//Sim Added
import Alamofire

class ThirdViewController: UIViewController, MDCSwipeToChooseDelegate {
    @IBOutlet weak var bottomCard: UIView?
    @IBOutlet weak var noMoreMatchesLabel: UILabel?
    @IBOutlet weak var inviteLabel: UILabel?
    var matches: MatchList?
    var topMatch: MatchModel?
    var mateControlsTag = 8
    var showCards: Bool = false
    
    //************  Top card is just an image
    var topCard: MDCSwipeToChooseView!
    var onLoad = true
    var cardIndex = 0
    var topCardIndex = 0
    var haveMatch = false
    var refreshLock = false
    var matchTap: UITapGestureRecognizer?
    var cardFrame: CGRect?
    var imageData: NSData?
    
    
    @IBOutlet weak var cardBlank: UIView?
    
    //************  Controls
    @IBOutlet weak var notNowButton: UIButton?
    @IBOutlet weak var infoButton: UIButton?
    @IBOutlet weak var interestedButton: UIButton?
    var controls = [UIButton]()
    
    //************  Bottom card layout
    @IBOutlet weak var bottomCardName: UILabel?
    @IBOutlet weak var bottomCardAge: UILabel?
    @IBOutlet weak var bottomCardDistance: UILabel?
    @IBOutlet weak var bottomCardImage: UIImageView?
    @IBOutlet weak var bottomCardTotalActivities: UILabel?
    @IBOutlet weak var bottomCardSharedActivities: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Discover";
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.matchTap = UITapGestureRecognizer()
        self.matchTap!.addTarget(self, action: "detailView")
        controls = [notNowButton!, infoButton!, interestedButton!]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //nextCard()
        if(NSUserDefaults.standardUserDefaults().boolForKey("newLogin") == true) {
            print("newLogin is true")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "newLogin")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ReadyForUse")
            showSigninScreen()
        }
         else if (FBSDKAccessToken.currentAccessToken() == nil) {
            print("no current access token.")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ReadyForUse")
            print("signinscreen from ThirdViewController.")
            showSigninScreen()
        } else {
            if(NSUserDefaults.standardUserDefaults().boolForKey("ReadyForUse") && (onLoad == true || NSUserDefaults.standardUserDefaults().boolForKey("NewMatchSettings"))){
                if self.topCard != nil {
                    self.topCard!.removeFromSuperview()
                    self.topCard = nil
                }
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "NewMatchSettings")
                if self.cardFrame == nil {
                    self.cardFrame = self.bottomCard!.frame
                }
                self.bottomCard!.hidden = true
                refreshMatches()
                return
            }
            if self.showCards == true {
                self.showCards = false
                self.nextCard()
            }
        }
    }
    
    func hideControls() {
        if self.notNowButton!.alpha == 1.0 {
            UIView.animateWithDuration(0.4) { () -> Void in
                for button in self.controls {
                    button.alpha = 0 }
            }
        }
    }
    
    func showControls() {
        if self.notNowButton!.alpha == 0.0 {
            UIView.animateWithDuration(0.4) { () -> Void in
                for button in self.controls {
                    button.alpha = 1 }
            }
        }
    }
    
    func refreshMatches() {
        print("refreshing matches with refresh lock of \(refreshLock).")
        if self.refreshLock == false {
            self.refreshLock = true
            ProfileManager.sharedInstance.getMatches { (success, matchList) -> Void in
                if success == true {
                    print("success!")
                    self.noMoreMatchesLabel!.hidden = true
                    self.inviteLabel!.hidden = true
                    self.onLoad = false
                    self.matches = matchList
                    self.cardIndex = 0
                    self.topCardIndex = 0
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.setBottomCard()
                        self.bottomCard!.hidden = false
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                            self.nextCard()
                            self.haveMatch = true
                        })
                        self.refreshLock = false
                    })
                } else {
                    self.noMoreMatches()
                    self.refreshLock = false
                }
            }
        } else {
            print("Refresh lock enabled. Waiting for previous request to complete.")
        }
    }
    
    func showSigninScreen() {
        print("trying to show signin screen.")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let termsView = storyBoard.instantiateViewControllerWithIdentifier("termsViewInitial")
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(termsView, animated: false, completion: nil)
        }

    
    func resetTopCard(onLoad: Bool) {
        //Our top card has no autolayout information. This ensures it is the same exact size as our bottom card.
        let options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.likedText = "Interested"
        options.nopeText = "Not Now"
        self.topCard = MDCSwipeToChooseView(frame: self.bottomCard!.frame, options: options)
        
        self.topCard.hidden = true
        self.view.addSubview(self.topCard!)
        self.topCard.addGestureRecognizer(self.matchTap!)
    }
    
    func setBottomCard() {
        if(self.matches != nil && self.cardIndex < self.matches!.matches.count){
            let user: MatchModel = self.matches!.matches[cardIndex]
            self.bottomCardName!.text = "\(user.firstName),"
            self.bottomCardAge!.text = "\(user.age)"
            self.bottomCardDistance!.text = Int(user.distance) < 2 ? "1 mile away" : "\(Int(user.distance)) miles away"
            
            self.bottomCardImage!.sd_setImageWithURL(NSURL(string: user.photo), placeholderImage: UIImage(named: "unknown_photo"), completed: {
                (image, error, type, url) in
                    if error == nil{
                        self.imageData = UIImageJPEGRepresentation(image, 1.0)
                    }
                    else {
                        self.imageData = nil
                    }
            })
            
            self.bottomCardTotalActivities!.text = "\(user.categories.count)"
            self.bottomCardSharedActivities!.text = "\(ProfileManager.sharedInstance.getSharedActivities(user).count)"
        }
    }
    
    func showTopCard(){
        resetTopCard(onLoad)
        UIGraphicsBeginImageContextWithOptions(self.bottomCard!.bounds.size, false, 0)
        var offset: CGFloat = 25.5
        let screenWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
        
        //iPhone 5, 5S - 26
        if screenWidth == 375{ //iPhone 6, 6S
            offset = 18
        }
        else if screenWidth == 414{ //iPhone 6 plus, 6s plus
            offset = 12.0
        }
        
        let frame = CGRectMake(self.bottomCard!.frame.origin.x - offset, self.bottomCard!.frame.origin.y - 16, self.cardFrame!.width, self.cardFrame!.height)
        self.bottomCard!.drawViewHierarchyInRect(frame, afterScreenUpdates: true)
        let newTopCardImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Make the card image visible again
        self.topCard.hidden = false
        //replace the card image with the image we just made
        self.topCard.imageView.image = newTopCardImage
        
        if self.cardIndex >= self.matches!.matches.count{
            return
        }
        
        let user: MatchModel = self.matches!.matches[self.topCardIndex]
        
        let realImageView: UIImageView! = UIImageView.init(frame: (self.bottomCardImage?.frame)!)
        
        if self.imageData == nil{
            realImageView.sd_setImageWithURL(NSURL(string: user.photo), placeholderImage: UIImage(named: "unknown_photo"))
        }
        else {
            realImageView.image = UIImage.init(data: self.imageData!)
        }

        realImageView.contentMode = .ScaleAspectFill
        realImageView.clipsToBounds = true
        self.topCard.imageView.insertSubview(realImageView, atIndex: 0)
    }
    
    func nextCard() {
//SIM        if ProfileManager.sharedInstance.tabBarController!.selectedIndex == 2 {
            print("ThirdViewController is current selected tab.")
            showTopCard()
            
            //Load the next match into the static card
            if self.cardIndex < self.matches!.matches.count {
                self.topMatch = self.matches!.matches[cardIndex]
                topCardIndex = cardIndex
                cardIndex++
                setBottomCard()
                self.showControls()
                self.hideInviteButton()
            } else {
                noMoreMatches()
            }
            //Last card?
            if self.cardIndex == self.matches!.matches.count {
                self.bottomCard!.hidden = true
            }
//SIM        }
/*SIM        else {
            print("setting cards to update next time ThirdViewController is shown.")
            self.showCards = true
        }
SIM*/
    }
    
    
    func noMoreMatches() {
        haveMatch = false
        if self.topCard != nil {
            self.topCard!.hidden = true
        }
        self.hideControls()
        self.showInviteButton()
        self.noMoreMatchesLabel!.alpha = 0.0
        self.noMoreMatchesLabel!.hidden = false
        self.inviteLabel!.alpha = 0.0
        self.inviteLabel!.hidden = false
        UIView.animateWithDuration(0.4) { () -> Void in
            self.noMoreMatchesLabel!.alpha = 1.0
            self.inviteLabel!.alpha = 1.0
        }
        print("No more matches!")
    }
    
    func showInviteButton() {
        let inviteIcon = FAKFontAwesome.shareSquareOIconWithSize(24.0)
        inviteIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        let inviteButton = UIButton(frame: CGRectMake(0.0, 0.0, 90.0, 40.0))
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(12.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedTitle = NSMutableAttributedString(string: "INVITE", attributes:attributes)
        inviteButton.setAttributedTitle(attributedTitle, forState: .Normal)
        inviteButton.setImage(inviteIcon.imageWithSize(CGSizeMake(24.0, 24.0)), forState: .Normal)
        inviteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 66, 0, 0)
        inviteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 24)
        inviteButton.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
        let inviteBarButton = UIBarButtonItem(customView: inviteButton)
        inviteBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = inviteBarButton

    }
    
    func share(sender: AnyObject?) {
        let sharingText = "Find someone nearby that wants to do an activity with you!"
        if let sharingURL = NSURL(string:"https://itunes.apple.com/us/app/fitmate-social/id947844643?ls=1&mt=8") {
            let shareables = [sharingText, sharingURL]
            let shareVC = UIActivityViewController(activityItems: shareables, applicationActivities: nil)
            shareVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard]
            
            self.presentViewController(shareVC, animated: true, completion: nil)
        }
    }
    
    func hideInviteButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func interested(sender: UIButton) {
        if haveMatch {
            self.topCard!.mdc_swipe(.Right)
            interested()
            
        }
    }
    
    @IBAction func notNow(sender: UIButton) {
        if haveMatch {
            self.topCard!.mdc_swipe(.Left)
            notNow()
        }
    }
    
    func detailView() {
//        self.performSegueWithIdentifier("MatchDetailSegue", sender: self)
        self.performSegueWithIdentifier("ProfileDetailSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
/*
        if segue.identifier == "MatchDetailSegue" {
                let detailView = segue.destinationViewController as! MateDetailViewController
                detailView.currentMate = self.matches!.matches[topCardIndex]
        }
*/
        if segue.identifier == "ProfileDetailSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            let topViewController:ProfileDetailController = navController.topViewController as! ProfileDetailController
            topViewController.currentMate = self.matches!.matches[topCardIndex]
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
/*
        if identifier == "MatchDetailSegue" {
            return haveMatch
        }
*/
        if identifier == "ProfileDetailSegue" {
            return haveMatch
        }
        
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func interested() {
        if topMatch != nil {
            ProfileManager.sharedInstance.interestedInMatch(topMatch!)
        }
    }
    
    func notNow() {
        if topMatch != nil {
            ProfileManager.sharedInstance.notNowForMatch(topMatch!)
        }
    }
    
    func view(view: UIView!, wasChosenWithDirection direction: MDCSwipeDirection) {
        if (direction == MDCSwipeDirection.Left) {
            notNow()
            nextCard()
        } else {
            nextCard()
            interested()
        }
    }


}
