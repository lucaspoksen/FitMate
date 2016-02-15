//
//  ActivitySettingController.swift
//  FitMate
//
//  Created by PSIHPOK on 11/19/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import Foundation
import UIKit

class ActivitySettingController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var m_PageControl: UIPageControl!
    
    @IBOutlet weak var m_ScrollView: UIScrollView!
    
    @IBOutlet weak var m_SaveButton: UIBarButtonItem!
    
    @IBOutlet weak var m_NextButton: UIBarButtonItem!
    
    static var g_ActivityController: ActivitySelectionController = ActivitySelectionController()
    
    var m_FromWhere:BearActivityControllerType!
  
    var m_ScreenArray = [UIViewController]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadScrollView()        
    }
    
    func loadScrollView(){
        let screenFrame = UIScreen.mainScreen().bounds
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
       
        for index in 0...3{
            let categoryScreen:ActivityCategory = storyboard.instantiateViewControllerWithIdentifier("ActivityCategory") as! ActivityCategory
            categoryScreen.currentCategoryIndex = index
            m_ScreenArray.append(categoryScreen as UIViewController)
            let page = categoryScreen.view
            
            page.frame = CGRectMake(screenFrame.size.width * CGFloat(index), 0, screenFrame.size.width, m_ScrollView.frame.height)
            m_ScrollView.addSubview(page)
        }
        
        let saveScreen:ProfileSaveController = storyboard.instantiateViewControllerWithIdentifier("ProfileSaveController") as! ProfileSaveController
        saveScreen.m_ParentController = self
        m_ScreenArray.append(saveScreen as UIViewController)
        saveScreen.view.frame = CGRectMake(screenFrame.size.width * 4, 0, screenFrame.size.width, m_ScrollView.frame.height)
        
        m_ScrollView.addSubview(saveScreen.view)
       
        m_ScrollView.contentSize = CGSizeMake(screenFrame.size.width * CGFloat(m_ScreenArray.count), m_ScrollView.frame.height)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        var page = Int((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        
        if (scrollView.contentOffset.x < pageWidth / 2){
            page = 0
        }
        
        m_PageControl.currentPage = page
        
        if page == m_ScreenArray.count - 1{
            m_NextButton.tintColor = UIColor.clearColor()
            m_NextButton.enabled = false
        }
        else {
            m_NextButton.tintColor = UIColor.whiteColor()
            m_NextButton.enabled = true
        }
        
    }
    
    func scrollPageWithIndex(pageIndex:Int){
        if (pageIndex >= m_ScreenArray.count || pageIndex < 0){
            return
        }
        
        let mainScreen = UIScreen.mainScreen().bounds
        var scrollToRect:CGRect = CGRect(x: 0, y: 0, width: mainScreen.width, height: m_ScrollView.frame.height)
        scrollToRect.origin.x = CGFloat(pageIndex) * mainScreen.width
        m_ScrollView.scrollRectToVisible(scrollToRect, animated: true)
    }
    
    @IBAction func onPageChanged(sender: AnyObject) {
        let pageIndex = m_PageControl.currentPage
        scrollPageWithIndex(pageIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSave(sender: AnyObject) {
        ActivitySettingController.saveActivitySettings(self, from: m_FromWhere)
    }
    
    static func saveActivitySettings(controller:UIViewController, from:BearActivityControllerType){
        let bNavBtnClicked = controller is ActivitySettingController
        let newCategoryList = ActivitySettingController.g_ActivityController.commitCategories()
        ProfileManager.sharedInstance.updateActivities(newCategoryList)
        
        var currentActivityController:ActivitySettingController!
        
        if (bNavBtnClicked){
            currentActivityController = controller as! ActivitySettingController
        }
        else {
            currentActivityController = (controller as! ProfileSaveController).m_ParentController
        }
        
        let presentingController = currentActivityController.presentingViewController
        
        currentActivityController.dismissViewControllerAnimated(true, completion: {() in
            if (from == BearActivityControllerType.FW_FIRSTUSE){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let activityNavController:FitMateTabBarController! = storyboard.instantiateViewControllerWithIdentifier("FitMateTabBarController") as! FitMateTabBarController
                activityNavController.m_bCreatedFirst = true
                
                presentingController?.presentViewController(activityNavController, animated: true, completion: nil)
            }
            else{
                ProfileManager.sharedInstance.tabBarController?.m_bCreatedFirst = false
                ProfileManager.sharedInstance.tabBarController?.selectedIndex = (ProfileManager.sharedInstance.tabBarController?.m_oldSelectedIndex)!
            }
        })
    }
    
    @IBAction func onNext(sender: AnyObject) {
        let pageIndex:Int = m_PageControl.currentPage
        scrollPageWithIndex(pageIndex + 1)
    }
    
}