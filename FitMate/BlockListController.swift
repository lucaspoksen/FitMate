//
//  BlockListController.swift
//  FitMate
//
//  Created by PSIHPOK on 12/5/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class BlockListController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var m_BlockTable: UITableView!
    var blockedUsers: [MatchModel]?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if blockedUsers != nil {
            return blockedUsers!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("BlockListCell") as! BlockListCell
        cell.m_PhotoImage!.sd_setImageWithURL(NSURL(string: self.blockedUsers![indexPath.row].photo), placeholderImage: UIImage(named: "unknown_photo"))
        cell.m_Name.text = blockedUsers![indexPath.row].firstName
        cell.tag = indexPath.row
        cell.m_UnblockButton!.addTarget(self, action: "unblockAlert:", forControlEvents: .TouchUpInside)
        cell.m_UnblockButton.tag = indexPath.row
        cell.m_Indicator.hidden = false
        cell.m_Indicator.startAnimating()
        cell.m_PhotoImage.alpha = 0.0
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        self.performSelector(Selector("makeCircleImage:"), withObject: cell, afterDelay: 0.5)
    }
    
    func makeCircleImage(cell:UITableViewCell){
        cell.layoutSubviews()
    }
    
    func unblockAlert(sender: UIButton) {
        let blockAlert = UIAlertController(title: "Unblock \(self.blockedUsers![sender.tag].firstName)?", message: "You and \(self.blockedUsers![sender.tag].firstName) will be able to message each other and see each other's profiles again.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let unblockAction = UIAlertAction(title: "Unblock", style: .Destructive) { (_) -> Void in
            ProfileManager.sharedInstance.unBlockUser(self.blockedUsers![sender.tag].ID, completion: { (success) -> Void in
                if success == true {
                    self.refresh()
                }
            })
        }
        blockAlert.addAction(cancelAction)
        blockAlert.addAction(unblockAction)
        self.presentViewController(blockAlert, animated: true, completion: nil)
    }
    
    func refresh() {
        ProfileManager.sharedInstance.blockedUsers { (success, matches) -> Void in
            if success == true && matches != nil {
                self.blockedUsers = matches!
                self.m_BlockTable!.reloadData()
            } else if matches == nil {
                self.blockedUsers = nil
                self.m_BlockTable!.reloadData()
            }
        }
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
