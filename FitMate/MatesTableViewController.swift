//
//  MatesTableViewController.swift
//  FitMate
//
//  Created by PSIHPOK on 11/25/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import FontAwesomeKit

class MatesTableViewController:UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var m_MateTable: UITableView!
    private var mates: Array<MateModel>?
    private let cellIdentifier = "MatesCell"
    var tagClouds = [ActivityTagCloudProvider]()
    let provider = MessagingProvider()
    var mateIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addInviteButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Sim make Block
        ProfileManager.sharedInstance.tabBarController!.setBadgeIcon(0)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        loadMates()
    }
    
    func getMates(completion: (result: Dictionary<String, String>, success: Bool) -> Void) {
        let user : User = ProfileManager.sharedInstance.userProfile
        let paramsDict: Dictionary<String, String> = [
            "uID"       :   user.uID,
            "uLat"      :   String(user.latitude),
            "uLog"      :   String(user.longitude),
        ]
        let urlString : String = "\(fitMateServer.apiURL)getMates.php"
        
        Alamofire.request(.GET, urlString, parameters: paramsDict).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let JSONData) :
                let json = JSON(JSONData)
                print("REQUEST: \(request)")
                print("RESULT: \(json)")
            case .Failure(_, let error) :
                print("FAILED at \(request) with Error: \(error)")
            }
        }
        
        completion(result: ["NONE":"NONE"], success: false)
    }
    
    func loadMates() {
        ProfileManager.sharedInstance.getMates { (result, success) -> Void in
            if success == true {
                print("got response.")
                if result.count > 0 {
                    print("actually have mates.")
                    let newResult = result.sort({x, y in
                        var xPriority = 0
                        var yPriority = 0
                        let xSeen = self.intervalLastSeen(x.matchedDate)
                        let ySeen = self.intervalLastSeen(y.matchedDate)
                        if xSeen > ySeen {
                            yPriority++
                        } else {
                            xPriority++
                        }
                        if NSUserDefaults.standardUserDefaults().objectForKey("\(x.ID)") != nil {
                            let storedMessage = NSUserDefaults.standardUserDefaults().objectForKey("\(x.ID)") as! String
                            print("last message: \(x.lastMessage) stored last message: \(storedMessage))")
                            if x.lastMessage != NSUserDefaults.standardUserDefaults().objectForKey("\(x.ID)") as! String {
                                //new message.
                                xPriority += 5
                            }
                        }
                        if NSUserDefaults.standardUserDefaults().objectForKey("\(y.ID)") != nil {
                            let storedYMessage = NSUserDefaults.standardUserDefaults().objectForKey("\(y.ID)") as! String
                            print("last message: \(y.lastMessage) stored last message: \(storedYMessage))")
                            if y.lastMessage != NSUserDefaults.standardUserDefaults().objectForKey("\(y.ID)") as! String {
                                //new message.
                                yPriority += 5
                            }
                        }
                        return xPriority > yPriority
                    })
                    self.mates = newResult
                    self.m_MateTable!.reloadData()
                }
            } else {
                print("failed to get mates.")
                self.noMates()
            }
        }
    }
    
    func matePriority(first: MateModel, second:MateModel) {
        
    }
    
    func noMates() {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let chatView = storyBoard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            chatView.mate = self.mates![indexPath.row]
            chatView.getMessages()
            self.navigationController!.pushViewController(chatView, animated: true)
        }
    }
    
    func addInviteButton(){
        let inviteIcon = FAKFontAwesome.shareSquareOIconWithSize(24.0)
        inviteIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        //let inviteImage = inviteIcon.imageWithSize(CGSizeMake(30.0, 30.0))
        let inviteButton = UIButton(frame: CGRectMake(0.0, 0.0, 90.0, 40.0))
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(12.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedTitle = NSMutableAttributedString(string: "INVITE", attributes:attributes)
        //attributedTitle.appendAttributedString(inviteIcon.attributedString())
        inviteButton.setAttributedTitle(attributedTitle, forState: .Normal)
        inviteButton.setImage(inviteIcon.imageWithSize(CGSizeMake(24.0, 24.0)), forState: .Normal)
        inviteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 66, 0, 0)
        inviteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 24)
        inviteButton.addTarget(self, action: "share:", forControlEvents: .TouchUpInside)
        let inviteBarButton = UIBarButtonItem(customView: inviteButton)
        inviteBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = inviteBarButton
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (self.mates != nil && self.mates!.count > 0) {
            return self.mates!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        return MatesCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        self.performSelector(Selector("makeCircleImage:"), withObject: cell, afterDelay: 0.5)
    }
    
    func makeCircleImage(cell:MateTableCell){
        
        cell.layoutSubviews()
    }
    
    func share(sender: AnyObject?) {
        let sharingText = "Find someone nearby that wants to do an activity with you!"
        let sharingURL = NSURL(string: "https://itunes.apple.com/us/app/fitmate-social/id947844643?ls=1&mt=8")
        let shareables = [sharingText, sharingURL!]
        print("SHARING URL: \(sharingURL)")
        let shareVC = UIActivityViewController(activityItems: shareables, applicationActivities: nil)
        shareVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact]
        
        self.presentViewController(shareVC, animated: true, completion: nil)
    }
    
    func intervalLastSeen(lastSeen:String) -> NSTimeInterval {
        print("last seen: \(lastSeen)")
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let correctionInterval = NSTimeInterval.init(NSTimeZone.localTimeZone().secondsFromGMT)
        var date = formatter.dateFromString(lastSeen)
        date = date!.dateByAddingTimeInterval(correctionInterval)
        print("date: \(date)")
        let interval = NSDate().timeIntervalSinceDate(date!)
        return interval
    }
    
    func daysSinceLastSeen(lastSeen: String) -> String {
        let interval = self.intervalLastSeen(lastSeen)
        //interval += correctionInterval
        let delta = Int(interval)
        print("delta:\(delta)")
        
        if delta < 1 {
            return "Connected just now"
        } else if delta < 121 {
            return "Connected 1 minute ago"
        } else if delta < 3600 {
            let minutes = Int(delta/60)
            return "Connected \(minutes) minutes ago"
        } else if delta < 86400 {
            let hours = Int(delta/60/60)
            return "Connected \(hours) hours ago"
        } else {
            let days = Int(delta/60/60/24)
            if days < 7 {
                return "Connected \(days) days ago"
            }
            let weeks = Int(days/7)
            return "Connected \(weeks) weeks ago"
        }
    }
    
    func MatesCellAtIndexPath(indexPath:NSIndexPath) -> MateTableCell {
        let cell = m_MateTable.dequeueReusableCellWithIdentifier("MateTableCell") as! MateTableCell
        let mate = mates![indexPath.row]
        cell.m_DetailButton!.addTarget(self, action: "mateDetail:", forControlEvents: .TouchUpInside)
        cell.m_DetailButton!.tag = indexPath.row
        cell.m_LastMessage!.text = mate.lastMessage
        cell.m_Indicator.hidden = false
        cell.m_Indicator.startAnimating()
        cell.m_Photo.alpha = 0.0
        
        if NSUserDefaults.standardUserDefaults().objectForKey("\(mate.ID)") != nil {
            let storedMessage = NSUserDefaults.standardUserDefaults().objectForKey("\(mate.ID)") as! String
            print("last message: \(mate.lastMessage) stored last message: \(storedMessage))")
            if mate.lastMessage != NSUserDefaults.standardUserDefaults().objectForKey("\(mate.ID)") as! String {
                //new message.
                cell.m_LastMessage!.font = UIFont.boldSystemFontOfSize(12.0)
            } else {
                cell.m_LastMessage!.font = UIFont.systemFontOfSize(12.0)
            }
        } else {
                cell.m_LastMessage!.font = UIFont.boldSystemFontOfSize(12.0)
        }
        
        cell.m_LastMessage.textColor = UIColor.whiteColor()
        
        NSUserDefaults.standardUserDefaults().setValue(mate.lastMessage, forKey: "\(mate.ID)")
        cell.m_NameLabel!.text = mate.firstName
        cell.m_Photo!.sd_setImageWithURL(NSURL(string: mate.photo)!, placeholderImage: UIImage(named: "unknown_photo"))
        cell.m_ConnectionTime!.text = daysSinceLastSeen(mate.matchedDate)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        print("about to return cell.")
        
        cell.m_BackgroundView.alpha = (indexPath.row % 2 == 0) ? 0.2 : 0.1
        
        return cell
    }
    
    func mateDetail(sender: UIButton) {
        self.mateIndex = sender.tag
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let detailNavController:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("ProfileDetailController") as! UINavigationController
        let detailController:ProfileDetailController = detailNavController.topViewController as! ProfileDetailController
        detailController.currentMatch = self.mates![self.mateIndex]
        self.presentViewController(detailNavController, animated: true, completion: nil)
    }
}
