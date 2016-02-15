//
//  ChatViewController.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/10/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import SDWebImage

class ChatViewController : JSQMessagesViewController  {
    //@IBOutlet var messageView: JSQMessagesCollectionView?
    var messages = [JSQMessage]()
    var sampleMessages: [JSQMessage]?
    var mate: MateModel?
    let messagesProvider = MessagingProvider()
    var mateImage: UIImage?
    var selfImage: UIImage?
    var sampleSelfImage: UIImage?
    var sampleMateImage: UIImage?
    var loading = false
    
    func populateSampleConversation() {
        self.senderDisplayName = ProfileManager.sharedInstance.userProfile.firstname
        self.senderId = ProfileManager.sharedInstance.userProfile.uID
        sampleSelfImage = UIImage(named: "sampleProfile")
        sampleMateImage = UIImage(named: "sampleMate")
        let messageA: JSQMessage = JSQMessage(senderId: self.senderId, displayName: "YES", text: "Hi Jessi! We have so many activities in common!")
        let messageB: JSQMessage = JSQMessage(senderId: "", displayName: "", text: "I know! Are you a big runner?")
        let messageC: JSQMessage = JSQMessage(senderId: self.senderId, displayName: "YES", text: "Yes, I love it!! Where do you like to run?")
        let messageD: JSQMessage = JSQMessage(senderId: "", displayName: "", text: "I usually go to the park on 14th! What about you?")
        let messageE: JSQMessage = JSQMessage(senderId: self.senderId, displayName: "YES", text: "Love running on the waterfront. We should meet up for a run this weekend.")
        sampleMessages = [messageA, messageB, messageC, messageD, messageE]
        self.navigationItem.title = "Jessi"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderDisplayName = ProfileManager.sharedInstance.userProfile.firstname
        self.senderId = ProfileManager.sharedInstance.userProfile.uID
        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        self.setBackground()
    }
    
    func setBackground(){
        self.collectionView?.backgroundColor = UIColor.clearColor()
        let backgroundImage:UIImage = UIImage(named: "activitybg")!
        let backgroundView:UIImageView = UIImageView(image: backgroundImage)
        backgroundView.frame = UIScreen.mainScreen().bounds
        backgroundView.contentMode = .ScaleToFill
        self.view.insertSubview(backgroundView, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView?.backgroundColor = UIColor.clearColor()
        
        if self.mate != nil {
            if self.sampleMateImage == nil {
                self.navigationItem.title = self.mate!.firstName
            }
            let blockButton = UIBarButtonItem(title: "Block", style: .Plain, target: self, action: "blockAlert")
            self.navigationItem.rightBarButtonItem = blockButton
            if sampleMateImage == nil {
                SDImageCache.sharedImageCache().queryDiskCacheForKey(self.mate!.photo) { (let image, _) -> Void in
                    self.mateImage = image
                    if self.selfImage != nil {
                        self.finishReceivingMessageAnimated(false)
                    }
                }
            } else {
                self.mateImage = self.sampleMateImage!
            }
            if sampleSelfImage == nil {
                SDImageCache.sharedImageCache().queryDiskCacheForKey(ProfileManager.sharedInstance.userProfile.photo, done: { (let image, _) -> Void in
                    self.selfImage = image
                    if self.mateImage != nil {
                        self.finishReceivingMessageAnimated(false)
                    }
                })
            } else {
                self.selfImage = self.sampleSelfImage!
            }
            //getMessages()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.messages.count > 0 {
            self.finishReceivingMessageAnimated(true)
            //self.messageView!.reloadData()
        }
    }
    
    func getMessages() {
        self.loading = true
        if sampleMessages != nil {
            self.messages = sampleMessages!
            self.loading = false
            return
        }
        self.messagesProvider.messagesForUser(self.mate!) { (result, success) -> Void in
            print("RESULT: \(result)")
            if result.count > 0 {
                self.messages = result
                self.loading = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("should have messages.")
                    NSUserDefaults.standardUserDefaults().setValue(self.messages.last!.text, forKey: "\(self.mate!.ID)")
                    print("just set \(self.messages.last!.text) as stored last message.")
                })
            }
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if self.mate != nil {
            self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text))
            self.finishSendingMessageAnimated(true)
            self.messagesProvider.sendMessage(self.mate!, message: text, completion: { (result) -> Void in
                NSUserDefaults.standardUserDefaults().setValue(text, forKey: "\(self.mate!.ID)")
                print("just set \(text) as stored last message.")
            })
        }
    }
    
    func blockAlert() {
        let alert = UIAlertController(title: "Block \(self.mate!.name)?", message: "You will no longer be able to send or receive messages with \(self.mate!.firstName) and your profiles will be hidden from each other.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let blockAction = UIAlertAction(title: "Block", style: .Destructive) { (_) -> Void in
            ProfileManager.sharedInstance.blockUser(self.mate!.ID)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC)*0.5)), dispatch_get_main_queue(), { () -> Void in
                self.navigationController!.popViewControllerAnimated(true)
            })
        }
        alert.addAction(cancelAction)
        alert.addAction(blockAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //if self.messages != nil {
            print("should have this many:\(self.messages.count)")
            return self.messages.count
        //}
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        var cell:JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.avatarImageView?.contentMode = .ScaleAspectFill
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        let formatter:JSQMessagesTimestampFormatter = JSQMessagesTimestampFormatter.sharedFormatter()
        var attribute:NSAttributedString!
        if indexPath.item == 0 {
            attribute = formatter.attributedTimestampForDate(message.date)
            return attribute
        }
        if indexPath.item - 1 > 0 {
            let previous = self.messages[indexPath.item - 1]
            if message.date.timeIntervalSinceDate(previous.date) / 60 > 10 {
                attribute = formatter.attributedTimestampForDate(message.date)
                return attribute
            }
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        if indexPath.item - 1 > 0 {
            let previous = self.messages[indexPath.item - 1]
            if self.messages[indexPath.item].date.timeIntervalSinceDate(previous.date) / 60 > 10 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.row]
        if message.senderDisplayName == "YES" || message.senderDisplayName == ProfileManager.sharedInstance.userProfile.firstname {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1))
        }
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2))
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.row]
        if (message.senderDisplayName == "YES" || message.senderDisplayName == ProfileManager.sharedInstance.userProfile.firstname) && self.selfImage != nil{
            return  JSQMessagesAvatarImageFactory.avatarImageWithImage(self.selfImage!, diameter: 64)
        }
        if (message.senderDisplayName != "YES" && message.senderDisplayName != ProfileManager.sharedInstance.userProfile.firstname) && self.mateImage != nil {
            return  JSQMessagesAvatarImageFactory.avatarImageWithImage(self.mateImage!, diameter: 64)
        }
        return  JSQMessagesAvatarImageFactory.avatarImageWithImage(JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(named: "unknown_photo"), withDiameter: 64), diameter: 64)
        //JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(named: "placeholder-1"), withDiameter: 64)
    }
}
