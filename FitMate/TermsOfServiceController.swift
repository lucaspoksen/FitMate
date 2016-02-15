//
//  TermsOfServiceController.swift
//  FitMate
//
//  Created by PSIHPOK on 11/19/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//


import UIKit

class TermsOfServiceController: UIViewController {
    
   
    @IBOutlet weak var m_WebView: UIWebView!
    
    @IBOutlet weak var m_NavItem: UINavigationItem!
    
    var m_AboutUs:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (m_AboutUs == false){
            m_NavItem.title = "Terms Of Service"
        }
        else {
            m_NavItem.title = "About Us"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if(m_WebView != nil) {
            let url:NSURL
            if (m_AboutUs == true){
               url = NSURL(string: "http://fitmatesocial.com/aboutus.html")!
            }
            else {
                url = NSBundle.mainBundle().URLForResource("Terms", withExtension: "htm")!
            }
            
            let request: NSURLRequest = NSURLRequest(URL: url)
            m_WebView!.loadRequest(request)
        }
    }
    
    @IBAction func onClickBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}