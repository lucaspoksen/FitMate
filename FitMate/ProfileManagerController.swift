//
//  ProfileManagerController.swift
//  FitMate
//
//  Created by PSIHPOK on 12/1/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import MARKRangeSlider
import QuartzCore
import SDWebImage
import FontAwesomeKit

enum SliderName{
    case SN_AGE
    case SN_DISTANCE
}

class ProfileManagerController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    @IBOutlet weak var m_ContentView: UIView!
    
    @IBOutlet weak var m_Name: UILabel!
  
    
    @IBOutlet weak var m_AboutMe: UITextView!
    
    @IBOutlet weak var m_FemaleRadio: DLRadioButton!
    
    @IBOutlet weak var m_BothRadio: DLRadioButton!
    
    @IBOutlet weak var m_MaleRadio: DLRadioButton!
    
    @IBOutlet weak var m_YearLabel: UILabel!
    
    @IBOutlet weak var m_AgeSlider: UISlider!
    
    @IBOutlet weak var m_MilesLabel: UILabel!
    
    @IBOutlet weak var m_DistanceSlider: UISlider!
    
    @IBOutlet weak var m_AgeSuperView: UIView!
    
    @IBOutlet weak var m_PhotoCollection: UICollectionView!
    
    var firstPosition:CGPoint = CGPointZero
    var lastPosition:CGPoint = CGPointZero
    
    var userProfile: User!
    
    var m_AgeRangeSlider: MARKRangeSlider?
    
    let imagePicker = UIImagePickerController()
    
    var imageToPick = 0
    
    var primaryImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBarButtons()
        addAgeRangeSlider()
        loadProfileImages()
        customizeSlider()
        addGestureForCollectionView()
    }
    
    func addGestureForCollectionView(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
        m_PhotoCollection.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = m_PhotoCollection.indexPathForItemAtPoint(gesture.locationInView(m_PhotoCollection))
            else {
                break
            }
            firstPosition = gesture.locationInView(m_PhotoCollection)
            m_PhotoCollection.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
        case UIGestureRecognizerState.Changed:
            m_PhotoCollection.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
        case UIGestureRecognizerState.Ended:
            m_PhotoCollection.endInteractiveMovement()
        default:
            m_PhotoCollection.cancelInteractiveMovement()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userProfile = ProfileManager.sharedInstance.userProfile
        
        print("----ProfileManager----")
        print(userProfile)
        print("----ProfileManager----")
        
        setSliderValue()
        setGenderType()
        setNameAndBio()
        setMilesLabel()
        setAgeLabel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ProfileManager.sharedInstance.saveUser()
    }
    
    //Load User Profile
    
    func setGenderType(){
        let showme = userProfile.settingShowMeFlag
        if (showme == 0){
            m_FemaleRadio.selected = true
        }
        else if (showme == 1){
            m_MaleRadio.selected = true
        }
        else{
            m_BothRadio.selected = true
        }
    }
    
    func setNameAndBio(){
        m_Name.text = userProfile.firstname
        m_AboutMe.text = userProfile.uAbout
        let toolBar = UIToolbar(frame: CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, 44.0))
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "saveAboutText")
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.items = [doneButton, spacer]
        m_AboutMe.inputAccessoryView = toolBar
    }
    
    func setSliderValue(){
        m_AgeRangeSlider?.leftValue = userProfile.settingShowAgeMin == 0 ? 18 : CGFloat(userProfile.settingShowAgeMin)
        m_AgeRangeSlider?.rightValue = userProfile.settingShowAgeMax == 0 ? 100 : CGFloat(userProfile.settingShowAgeMax)
        m_DistanceSlider.minimumValue = 0
        m_DistanceSlider.maximumValue = 200
        m_DistanceSlider.value = Float(userProfile.settingDistance)
    }
    
    func addNavBarButtons(){
        //Add Logout Button
        let logoutBarButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "logoutAction:")
        let logout = FAKFontAwesome.powerOffIconWithSize(24.0)
        logout.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        let logoutImage = logout.imageWithSize(CGSizeMake(30.0, 30.0))
        logoutBarButton.image = logoutImage
        logoutBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = logoutBarButton
        
        //Add Setting Button
        let settingBarButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "settingAction:")
        let cog = FAKFontAwesome.cogIconWithSize(24.0)
        cog.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        let cogImage = cog.imageWithSize(CGSizeMake(30.0, 30.0))
        settingBarButton.image = cogImage
        settingBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = settingBarButton
    }
    
    func addAgeRangeSlider(){
        if (m_AgeRangeSlider == nil){
            m_AgeRangeSlider = MARKRangeSlider(frame: m_AgeSlider.frame)
            m_AgeRangeSlider!.translatesAutoresizingMaskIntoConstraints = false
            m_AgeRangeSlider!.maximumValue = 100.0
            m_AgeRangeSlider!.minimumValue = 18.0
            m_AgeRangeSlider!.rightValue = 100.0
            m_AgeRangeSlider!.leftValue = 18.0
            m_AgeRangeSlider!.minimumDistance = 10.0
            m_AgeSlider.hidden = true
            
            m_AgeRangeSlider?.addTarget(self, action: "ageSliderChanged", forControlEvents: UIControlEvents.ValueChanged)
            
            m_AgeSuperView.addSubview(m_AgeRangeSlider!)
            
            let views = ["container": m_AgeSuperView!, "slider": m_AgeRangeSlider!]
            let sizeConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[slider]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
            let heightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[slider(31.0)]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
            m_AgeRangeSlider?.addConstraints(heightConstraint)
            m_AgeSuperView.addConstraints(sizeConstraints)
            
            m_AgeSuperView!.addConstraint(NSLayoutConstraint(item: m_AgeRangeSlider!, attribute: .CenterY, relatedBy: .Equal, toItem: m_AgeSuperView!, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        }
    }
    
    func customizeSlider(){
    
    }
    
    func loadProfileImages(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
    }
    
    //Updating User Profile Event
    
    func ageSliderChanged() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NewMatchSettings")
        self.m_YearLabel.text = "\(Int(m_AgeRangeSlider!.leftValue)) - \(Int(m_AgeRangeSlider!.rightValue))"
        ProfileManager.sharedInstance.userProfile.settingShowAgeMin = Int16(m_AgeRangeSlider!.leftValue)
        ProfileManager.sharedInstance.userProfile.settingShowAgeMax = Int16(m_AgeRangeSlider!.rightValue)
        ProfileManager.sharedInstance.saveUser()
    }
    
    func setAgeLabel(){
        self.m_YearLabel.text = "\(Int(m_AgeRangeSlider!.leftValue)) - \(Int(m_AgeRangeSlider!.rightValue))"
        ProfileManager.sharedInstance.saveUser()
    }
    
    func setMilesLabel(){
        if Int(m_DistanceSlider.value) <= 1 {
            m_MilesLabel.text = "\(Int(m_DistanceSlider.value)) MILE"
        } else {
            m_MilesLabel.text = "\(Int(m_DistanceSlider.value)) MILES"
        }
        ProfileManager.sharedInstance.saveUser()
    }
    
    @IBAction func distanceSliderChange(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NewMatchSettings")
        ProfileManager.sharedInstance.userProfile.settingDistance = Int16(m_DistanceSlider.value)
        if Int(m_DistanceSlider.value) <= 1 {
            m_MilesLabel.text = "\(Int(m_DistanceSlider.value)) MILE"
        } else {
            m_MilesLabel.text = "\(Int(m_DistanceSlider.value)) MILES"
        }
        ProfileManager.sharedInstance.saveUser()
    }
    
    func saveAboutText(){
        self.view.endEditing(true)
        ProfileManager.sharedInstance.userProfile.uAbout = m_AboutMe.text
        ProfileManager.sharedInstance.saveUser()
        ProfileManager.sharedInstance.updateUser(m_AboutMe.text, tagline: "")
    }
    
    @IBAction func onFemaleRadioClicked(sender: AnyObject) {
        if (m_FemaleRadio.selected == true){
            radioSelected(0)
        }
    }
    
    @IBAction func onBothRadioClicked(sender: AnyObject) {
        if (m_BothRadio.selected == true){
            radioSelected(2)
        }
    }
    
    @IBAction func onMaleRadioClicked(sender: AnyObject) {
        if (m_MaleRadio.selected == true){
            radioSelected(1)
        }
    }
    
    func radioSelected(radioNum:Int16){
        ProfileManager.sharedInstance.userProfile.settingShowMeFlag = radioNum
        ProfileManager.sharedInstance.saveUser()
    }
    
    //Navigation Bar Action
    
    func logoutAction(sender: AnyObject){
        let logoutConfirm: UIAlertController = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        let yesAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default) { (action) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.confirmLogout()
            })
        }
        logoutConfirm.addAction(cancelAction)
        logoutConfirm.addAction(yesAction)
        self.presentViewController(logoutConfirm, animated: true, completion: nil)
    }
    
    func confirmLogout() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ReadyForUse")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "newLogin")
        (UIApplication.sharedApplication().delegate! as! AppDelegate).showSignInScreen()
    }
    
    func settingAction(sender: AnyObject){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingController = storyboard.instantiateViewControllerWithIdentifier("SettingController")
        self.presentViewController(settingController, animated: true, completion: nil)
    }
    
    @IBAction func onClickChangeActivity(sender: AnyObject) {
        ProfileManager.sharedInstance.tabBarController?.m_oldSelectedIndex = 0
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let activityController:LightContentNavController = storyboard.instantiateViewControllerWithIdentifier("SaveActivityController") as! LightContentNavController
        let topViewController:ActivitySettingController = activityController.topViewController as! ActivitySettingController
        topViewController.m_FromWhere = BearActivityControllerType.FW_NORMALUSE
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    
    
    func squareView(imageName: String) -> UIView {
        let square = UIView(frame: CGRectMake(0.0, 0.0, 96, 96))
        square.contentMode = .ScaleAspectFill
        square.clipsToBounds = true
        let img = UIImageView(frame: square.frame)
        img.contentMode = .ScaleAspectFill
        square.addSubview(img)
        let views = ["img" : img, "square": square]
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[square(96)]", options:.AlignAllCenterY , metrics: nil, views: views)
        square.addConstraints(constraints)
        let sizeConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[img(96)]|", options: .AlignAllCenterY, metrics: nil, views: views)
        square.addConstraints(sizeConstraint)
        square.layer.rasterizationScale = UIScreen.mainScreen().scale
        square.layer.shouldRasterize = true
        img.sd_setImageWithURL(NSURL(string: imageName), placeholderImage: UIImage(named: "unknown_photo"), completed: {
            (image, error, cacheType, imageURL) in
            SDImageCache.sharedImageCache().storeImage(image, forKey: "primaryPic")
        })
        
        //img.image = UIImage(named: "sampleProfile")
        return square
    }
    
    func squareView(imageIndex: Int, canDelete: Bool) -> UIView {
        let square = UIView(frame: CGRectMake(0.0, 0.0, 96, 96))
        square.contentMode = .ScaleAspectFill
        square.clipsToBounds = true
        let img = UIImageView(frame: square.frame)
        img.contentMode = .ScaleAspectFill
        square.addSubview(img)
        let views = ["img" : img, "square": square]
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[square(96)]", options:.AlignAllCenterY , metrics: nil, views: views)
        square.addConstraints(constraints)
        let sizeConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[img(96)]|", options: .AlignAllCenterY, metrics: nil, views: views)
        square.addConstraints(sizeConstraint)
        if canDelete == true {
            let deleteIcon = FAKFontAwesome.timesCircleIconWithSize(18.0)
            deleteIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())
            let deleteImage = deleteIcon.imageWithSize(CGSizeMake(16.0, 16.0))
            let deleteView = UIImageView(frame: CGRectMake(4.0, 74.0, 18.0, 18.0))
            deleteView.contentMode = .Center
            deleteView.image = deleteImage
            square.addSubview(deleteView)
            let deleteButton = UIButton(frame: CGRectMake(0.0, 66.0, 30.0, 30.0))
            deleteButton.addTarget(self, action: "deleteProfileImageAtButtonTag:", forControlEvents: .TouchUpInside)
            deleteButton.tag = imageIndex
            square.addSubview(deleteButton)
        }
        square.layer.rasterizationScale = UIScreen.mainScreen().scale
        square.layer.shouldRasterize = true
        img.sd_setImageWithURL(NSURL(string: "profilePic\(imageIndex)"), placeholderImage: UIImage(named: "unknown_photo"))
        return square
    }
    
    func addImagesView() -> UIView {
        let square = UIView(frame: CGRectMake(0.0, 0.0, 96, 96))
        square.backgroundColor = UIColor.lightGrayColor()
        let label = UILabel(frame: square.frame)
        label.font = UIFont.systemFontOfSize(40.0)
        label.textColor = UIColor.whiteColor()
        label.text = "+"
        label.textAlignment = NSTextAlignment.Center
        square.addSubview(label)
        return square
    }
    
    func updatePhotos() {
        let count = NSUserDefaults.standardUserDefaults().integerForKey("profilePhotoCount")
        var images = [UIImage]()
        //images.append(sd_)
        for var i = 1; i < count; i++ {
            images.append(SDImageCache.sharedImageCache().imageFromDiskCacheForKey("profilePic\(i)"))
        }
        ProfileManager.sharedInstance.replacePhotos(images)
    }
    
    func replacePhotos(source:Int, dest:Int){
        if (source != 0 && dest != 0){
            let sourceImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("profilePic\(source)")
            let destImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("profilePic\(dest)")
            SDImageCache.sharedImageCache().storeImage(sourceImage, forKey: "profilePic\(dest)")
            SDImageCache.sharedImageCache().storeImage(destImage, forKey: "profilePic\(source)")
        }
        else {
            if (source == 0){
                let sourceImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("primaryPic")
                let destImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("profilePic\(dest)")
                SDImageCache.sharedImageCache().storeImage(sourceImage, forKey: "profilePic\(dest)")
                SDImageCache.sharedImageCache().storeImage(destImage, forKey: "primaryPic")

            }
            else if (dest == 0){
                let sourceImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("primaryPic")
                let destImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("profilePic\(source)")
                SDImageCache.sharedImageCache().storeImage(sourceImage, forKey: "profilePic\(source)")
                SDImageCache.sharedImageCache().storeImage(destImage, forKey: "primaryPic")
            }
            ProfileManager.sharedInstance.userProfile.photo = "primaryPic"
            ProfileManager.sharedInstance.saveUser()
            self.m_PhotoCollection.reloadData()
        }
        self.updatePhotos()
    }
    
    func deleteProfileImageAtButtonTag(sender: UIButton) {
        if NSUserDefaults.standardUserDefaults().valueForKey("profilePhotoCount") != nil {
            let count = NSUserDefaults.standardUserDefaults().integerForKey("profilePhotoCount")
            self.deleteProfileImageAtIndex(sender.tag, count: count)
        }
    }
    
    func deleteProfileImageAtIndex(index:Int, count: Int){
        for var imageIndex = index; imageIndex < count; imageIndex++ {
            let image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("profilePic\(imageIndex + 1)")
            SDImageCache.sharedImageCache().storeImage(image, forKey: "profilePic\(imageIndex)")
        }
        NSUserDefaults.standardUserDefaults().setInteger(count - 1, forKey: "profilePhotoCount")
        self.updatePhotos()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.m_PhotoCollection.reloadData()
        })
    }
    
    //ImagePickerController Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("imageToPick: \(self.imageToPick)")
            SDImageCache.sharedImageCache().storeImage(image, forKey: "profilePic\(self.imageToPick)")
            if NSUserDefaults.standardUserDefaults().valueForKey("profilePhotoCount") == nil {
                NSUserDefaults.standardUserDefaults().setInteger(2, forKey: "profilePhotoCount")
                self.updatePhotos()
            } else {
                let count = NSUserDefaults.standardUserDefaults().integerForKey("profilePhotoCount")
                if self.imageToPick >= count {
                    NSUserDefaults.standardUserDefaults().setInteger(count + 1, forKey: "profilePhotoCount")
                    self.updatePhotos()
                }
            }
        }
        dismissViewControllerAnimated(true) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.m_PhotoCollection.reloadData()
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if NSUserDefaults.standardUserDefaults().objectForKey("profilePhotoCount") == nil {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "profilePhotoCount")
            return 2
        }
        let count = NSUserDefaults.standardUserDefaults().integerForKey("profilePhotoCount")
        if count < 5 {
            return count + 1
        }
        return count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
/////////////////////////
        var full = false
        if NSUserDefaults.standardUserDefaults().valueForKey("profilePhotoCount") != nil {
            if NSUserDefaults.standardUserDefaults().integerForKey("profilePhotoCount") == 5 {
                full = true
            }
        }
        let count = self.collectionView(collectionView, numberOfItemsInSection: 0)
        let index = indexPath.row
        if index == count - 1 && (count < 5 || !full) {
            let view = addImagesView()
            cell.addSubview(view)
        } else if index == 0 {
            let view = squareView(ProfileManager.sharedInstance.userProfile.photo)
            cell.addSubview(view)
            print(ProfileManager.sharedInstance.userProfile.photo)
            
        } else {
            print("picking item called profilePic\(index)")
            let view = squareView(index, canDelete: true)
            cell.addSubview(view)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let count = self.collectionView(collectionView, numberOfItemsInSection: 0)
        let index = indexPath.row
        if (index == count - 1 && count <= 5)
        {
            self.imageToPick = index
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath){
        
        let count = self.collectionView(collectionView, numberOfItemsInSection: 0)
        if (sourceIndexPath.row == count - 1 || destinationIndexPath.row == count - 1){
            self.m_PhotoCollection.reloadData()
            return
        }
        
        self.replacePhotos(sourceIndexPath.row, dest: destinationIndexPath.row)
    }
    
}
