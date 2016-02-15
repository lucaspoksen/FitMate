//
//  ProfileDetailController.swift
//  FitMate
//
//  Created by PSIHPOK on 12/14/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit
import SDWebImage
import QuartzCore


let tableRowHeight:CGFloat = 25.0

class ProfileDetailController: UIViewController, iCarouselDataSource, iCarouselDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var m_NameLabel: UILabel!
    
    @IBOutlet weak var m_AgeLabel: UILabel!
    
    @IBOutlet weak var m_DistanceLabel: UILabel!
    
    @IBOutlet weak var m_PhotoList: iCarousel!
    
    @IBOutlet weak var m_AboutMe: UITextView!
    
    @IBOutlet weak var m_ActivityTable: ActivityTable!
    
    @IBOutlet weak var m_SharedActivityTable: ActivityTable!
    
    @IBOutlet weak var m_PageControl: UIPageControl!
    
    @IBOutlet weak var m_ContentView: UIView!
    
    @IBOutlet weak var m_SharedActivityLabel: UILabel!
    
    @IBOutlet weak var m_ScrollView: UIScrollView!
    
    
    
    
    var currentMate: MatchModel?
    var currentMatch: MateModel?
    var showUserProfile: Bool = false
    var sharedCategoriesList: [String]?
    var gallery = [UserImage]()
    var categoryList: [UserCategory]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readyCategoryList()
        self.m_ContentView.bringSubviewToFront(self.m_PageControl!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.m_PhotoList!.pagingEnabled = true

        self.m_PhotoList!.reloadData()
        self.resetHeightControlls()
    }
    
    func readyCategoryList(){
        if (self.showUserProfile == true){
            self.categoryList = ProfileManager.sharedInstance.activities().categories
        }
        else {
            if (self.currentMate != nil){
                self.categoryList = self.currentMate?.categories
            }
            else {
                self.categoryList = self.currentMatch?.categories
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
        let textRect = contentSizeRectForTextView(self.m_AboutMe)
        self.m_AboutMe.frame = textRect
    }
    
    func contentSizeRectForTextView(textView:UITextView) -> CGRect{
        textView.layoutManager.ensureLayoutForTextContainer(textView.textContainer)
        let textBounds = textView.layoutManager.usedRectForTextContainer(textView.textContainer)
        let width:CGFloat = CGFloat(ceil(textBounds.size.width + textView.textContainerInset.left + textView.textContainerInset.right))
        let height:CGFloat = CGFloat(ceil(textBounds.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom))
        return CGRectMake(0, 0, width, height)
    }
    
    func resetHeightControlls(){
        //Text View Height Reset
        let spacing:CGFloat = 8.0
        
        self.m_ActivityTable.frame.size.height = CGFloat(self.sharedCategoriesList!.count) * tableRowHeight
        let origin:CGPoint = CGPoint(x: self.m_SharedActivityTable.frame.origin.x, y: self.m_ActivityTable.frame.origin.y + self.m_ActivityTable.frame.height + spacing)
        self.m_SharedActivityLabel.frame = CGRectMake(origin.x, origin.y, self.m_SharedActivityLabel.frame.width, self.m_SharedActivityLabel.frame.height)
        
        let size:CGSize = CGSize(width: self.m_SharedActivityTable.frame.width, height: CGFloat(self.categoryList!.count) * tableRowHeight)
        self.m_SharedActivityTable.frame = CGRectMake(origin.x, origin.y + self.m_SharedActivityLabel.frame.height + spacing, size.width, size.height)
        self.m_ScrollView.contentSize = CGSizeMake(self.m_ContentView.frame.width, self.m_SharedActivityTable.frame.height + self.m_SharedActivityTable.frame.origin.y + spacing)
    }
    
    func setupView(){
        if (self.showUserProfile == true){
            
            let rawGallery = ProfileManager.sharedInstance.userProfile.gallery
            for image in rawGallery {
                let galleryImage = image as! GalleryPhoto
                let nextImage: UserImage = UserImage(gID:galleryImage.gID!.integerValue, photo:galleryImage.photo!)
                self.gallery.append(nextImage)
            }
            
            self.m_PageControl!.numberOfPages = self.gallery.count+1
            self.m_NameLabel!.text = "\(ProfileManager.sharedInstance.userProfile.firstname),"
            self.m_AgeLabel!.text = "\(ProfileManager.sharedInstance.userProfile.age)"
            self.m_DistanceLabel!.text = "Right here!"
            self.m_AboutMe!.text = "\(ProfileManager.sharedInstance.userProfile.uAbout)"
            self.m_AboutMe!.font = self.m_AboutMe!.font?.fontWithSize(14.0)
            self.sharedCategoriesList = ["NONE"]
        }
        else {
            if (self.currentMate != nil){
                self.gallery = self.currentMate!.gallery
                self.m_PageControl!.numberOfPages = self.gallery.count+1
                self.m_NameLabel!.text = "\(self.currentMate!.firstName),"
                self.m_AgeLabel!.text = "\(self.currentMate!.age)"
                self.m_DistanceLabel!.text = Int(self.currentMate!.distance) < 2 ? "1 mile away" : "\(Int(self.currentMate!.distance)) miles away"
                self.m_AboutMe!.text = self.currentMate!.about
                self.sharedCategoriesList = ProfileManager.sharedInstance.getSharedActivityNames(self.currentMate!)
            }
            
            if (self.currentMatch != nil){
                self.gallery = self.currentMatch!.gallery
                self.m_PageControl!.numberOfPages = self.gallery.count+1
                self.m_NameLabel!.text = "\(self.currentMatch!.firstName),"
                self.m_AgeLabel!.text = "\(self.currentMatch!.age)"
                self.m_DistanceLabel!.text = Int(self.currentMatch!.distance) < 2 ? "1 mile away" : "\(Int(self.currentMatch!.distance)) miles away"
                self.m_AboutMe!.text = self.currentMatch!.about
                self.sharedCategoriesList = ProfileManager.sharedInstance.sharedActivitesFromCategories(self.currentMatch!.categories)
            }
        }
        self.m_AboutMe!.textColor = UIColor.whiteColor()
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        print("number of items: \(self.gallery.count + 1)")
        return self.gallery.count + 1
    }
    
    func carouselItemWidth(carousel: iCarousel) -> CGFloat {
        return self.m_PhotoList!.frame.size.width
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        let square = UIView(frame: self.m_PhotoList!.frame)
        square.clipsToBounds = true
        let imageView = UIImageView(frame: square.frame)
        imageView.contentMode = .ScaleAspectFill
        square.addSubview(imageView)
        if index == 0 {
            if self.showUserProfile == true {
                imageView.sd_setImageWithURL(NSURL(string: ProfileManager.sharedInstance.userProfile.photo), placeholderImage: UIImage(named: "unknown_photo"))
            }
            else {
                imageView.sd_setImageWithURL(NSURL(string: (self.currentMate != nil ? self.currentMate!.photo : self.currentMatch!.photo) ), placeholderImage: UIImage(named: "unknown_photo"))
            }
        } else {
            self.validURL(self.gallery[index - 1].photo)
            imageView.sd_setImageWithURL(self.validURL(self.gallery[index - 1].photo), placeholderImage: UIImage(named: "unknown_photo"))
        }
        return square
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        self.m_PageControl!.currentPage = carousel.currentItemIndex
    }
    
    func validURL(photoAddress: String) -> NSURL {
        print("raw address: \(photoAddress)")
        let testComponents = photoAddress.substringToIndex(photoAddress.startIndex.advancedBy(8))
        print("test:\(testComponents)")
        if testComponents == "http:///" {
            let addressComponents = photoAddress.substringFromIndex(photoAddress.startIndex.advancedBy(16))
            let URLString = "\(fitMateServer.apiURL)\(addressComponents)"
            print("trying this address:\(URLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)")
            return NSURL(string: URLString)!
        }
        return NSURL(string: photoAddress)!
    }
    
    @IBAction func onClose(sender: AnyObject) {
                self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (tableView == m_ActivityTable){
            print(self.sharedCategoriesList!.count)
            return self.sharedCategoriesList!.count
        }
        else if (tableView == m_SharedActivityTable){
            print(self.categoryList!.count)
            return self.categoryList!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell:ActivityTableCell = tableView.dequeueReusableCellWithIdentifier("DetailActivityCell") as! ActivityTableCell
        
        if (tableView == m_ActivityTable){
            cell.m_ActivityLabel.text = self.sharedCategoriesList![indexPath.row]
        }
        else if (tableView == m_SharedActivityTable){
            cell.m_ActivityLabel.text = self.categoryList![indexPath.row].name
        }
        
        return cell
    }
    
    
}
