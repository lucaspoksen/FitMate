
//  ProfileManager.swift
//  FitMate
//
//  Created by Derek Sanchez on 8/8/15.
//  Copyright (c) 2015 Dramatech. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import CoreData
import Alamofire
import SwiftyJSON
import JSQMessagesViewController

class ProfileManager {
    static let sharedInstance = ProfileManager()
    var matches = [MatchModel]()
    var mates = [MateModel]()
    let mainContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var tabBarController: FitMateTabBarController?
    lazy var userProfile: User = {
        self.getCurrentUser()
    }()
    
    var bLoadUserProfileComplete:Bool = false
  
    
    private init() {

    }
    
    func getUserImage() {
        
    }
    
    func setMatesBadge(count: Int) {
        print("setting mates badge with count of \(count)")
        var total = count
        if count != 0 {
            total = count + UIApplication.sharedApplication().applicationIconBadgeNumber
        }

        if self.tabBarController != nil {
            self.tabBarController!.setBadgeIcon(total)
            UIApplication.sharedApplication().applicationIconBadgeNumber = total
        }
    }
    
    func deleteAccount() {
        let URLString = "\(fitMateServer.apiURL)deleteAccount.php?uID=\(self.userProfile.uID)"
        let URL = NSURL(string: URLString)
        Alamofire.request(.GET, URL!).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let jsonObject):
                print("Account deleted successfully with data: \(jsonObject)")
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ReadyForUse")
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "TermsAccepted")
                    //Bring up the login interface.

                (UIApplication.sharedApplication().delegate! as! AppDelegate).showSignInScreen()

                //})
            case .Failure(_, let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func getMatches(completion: ((success: Bool, matches: MatchList) -> Void)? = nil ) {
        let paramsDict: Dictionary<String, String> = [
            "uID"           :   "\(self.userProfile.uID)",
            "uDistance"     :   self.userProfile.settingDistance < 1 ? "5" : "\(self.userProfile.settingDistance)",
            "uShowAgeMin"   :   self.userProfile.settingShowAgeMin == 0 ? "1" : "\(self.userProfile.settingShowAgeMin)",
            "uShowAgeMax"   :   self.userProfile.settingShowAgeMax == 0 ? "100" : "\(self.userProfile.settingShowAgeMax)",
            "uShowMeFlag"   :   "\(self.userProfile.settingShowMeFlag)",
            "uLat"          :   "\(self.userProfile.latitude)",
            "uLog"          :   "\(self.userProfile.longitude)",
            "uDevice"       :   self.userProfile.device,
        ]
        print("Parameters: \(paramsDict)")
        
        let URLString: String = "\(fitMateServer.apiURL)getMatchingUsers.php".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        Alamofire.request(.GET, URLString, parameters: paramsDict).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let jsonObject):
                let json = JSON(jsonObject)
                print("Success with Request: \(request!.URLString)")
                var matchArray = [MatchModel]()
                for (_, subJson) in json {
                    let match = subJson.dictionaryValue
                    if let flag = match["flag"] {
                        if flag == "2" {
                            print("No matches.")
                            let emptyList = MatchList(matches: [])
                            completion!(success: false, matches: emptyList)
                            return
                        }
                    }
                    let matchModel: MatchModel = self.makeMatchModel(match)
                    //Avoid returning the current user.
                    if matchModel.ID != self.userProfile.uID {
                        matchArray.append(matchModel)
                    }
                }
                let list = MatchList(matches: matchArray)
                self.matches = matchArray
                completion!(success: true, matches: list)
            case .Failure(_, let error):
                print("Request failed with error: \(error)")
            }
            
        }
    }
    
    func blockUser(uID: String) {
        let URLString = "\(fitMateServer.apiURL)blockAccount.php?uID=\(self.userProfile.uID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)&buID=\(uID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
        Alamofire.request(.GET, URLString).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let jsonData):
                print("success with JSON-blockUser:\(jsonData)")
            case .Failure(_, let error):
                print("failure with error:\(error)")
            }
        }
    }
    
    func unBlockUser(uID: String, completion: (success: Bool) -> Void) {
        let URLString = "\(fitMateServer.apiURL)unblockAccount.php?uID=\(self.userProfile.uID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)&buID=\(uID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
        Alamofire.request(.GET, URLString).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let jsonData):
                print("success with JSON-unBlockUser:\(jsonData)")
                completion(success: true)
                self.getMates({ (result, success) -> Void in

                })
            case .Failure(_, let error):
                print("failure with error:\(error)")
                completion(success: false)
            }
        }
    }
    
    func blockedUsers(completion: (success: Bool, matches:[MatchModel]?) -> Void) {
        let URLString = "\(fitMateServer.apiURL)getBlockUsers.php?uID=\(self.userProfile.uID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
        Alamofire.request(.GET, URLString).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let json):
                let jsonData = JSON(json)
                var retval = [MatchModel]()
                for (_, subJson) in jsonData {
                    let jsonDictionary = subJson.dictionaryValue
                    print("json dictionary-getBlockUsers:\(jsonDictionary)")
                    if let flag = jsonDictionary["flag"] {
                      if flag.stringValue == "2" {
                            print("no blocked users.")
                            completion(success: true, matches: nil)
                            return
                        }
                    }
                    //print("BLOCKED USERS FRAGMENT: \(subJson)")
                    let user: MatchModel = self.makeMatchModel(jsonDictionary)
                    retval.append(user)
                }
                completion(success: true, matches:retval)
            case .Failure(_, let error):
                print("Failed to get blocked users with error: \(error) and request: \(request)")
                completion(success: false, matches: nil)
            }
        }
    }
    
    func deletePhoto(photoID: Int) {
        let URLString = "\(fitMateServer.apiURL)deletePhoto.php?uID=\(self.userProfile.uID)&gID=\(photoID)"
        Alamofire.request(.GET, URLString).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let json):
                print("Deleted photo successfully with response:\(json)")
            case .Failure(_, let error):
                print("failed to delete photo with error:\(error)")
            }
        }
    }
    
    func replacePhotos(photos: [UIImage]) {
        self.apiServerRequest { (result, user) -> Void in
            print("RESULT: \(result)")
            if result == true && user != nil {
                let gallery = user!.gallery
                for galleryPhoto in gallery {
                    self.deletePhoto(galleryPhoto.gID)
                }
            }
        }
        photoQueue(photos, i: 0)
    }
    
    func photoQueue(photos:[UIImage], i: Int) {
        print("adding photo \(i)")
        if i == photos.count {
            return
        }
        self.addPhoto(photos[i], index:i, type: 2) { (success) -> Void in
            sleep(1)
            let j = i + 1
            self.photoQueue(photos, i: j)
        }
    }
    
    
    func addPhoto(photo: UIImage, index: Int, type: Int, completion: (success: Bool) -> Void) {
            // Gallery photos (so not main photo).
            //Connect to the server at uploadPhoto.php
            let URLString = "\(fitMateServer.apiURL)uploadPhoto.php?uID=\(self.userProfile.uID)&nPhotoType=\(type)"
            //let data = MultipartFormData()
            //data.appendBodyPart(data: UIImageJPEGRepresentation(photo, 0.7)!, name: "userPhotoData", fileName: "image", mimeType: "image/png")
            let name = "galleyPhoto\(index+1)"
            print("name: \(name)")
            Alamofire.upload(.POST, URLString, multipartFormData: { (let data) -> Void in
                data.appendBodyPart(data: UIImageJPEGRepresentation(photo, 0.7)!, name: "userPhotoData", fileName: "image", mimeType: "image/png")

                }, encodingCompletion: { (result) -> Void in
                    switch result {
                    case .Success(let upload, _, _):
                        print("success?")
                        upload.responseJSON { (request, response, data) -> Void in
                            switch data {
                            case .Success(let json):
                                print("upload response: \(json)")
                                completion(success: true)
                            case .Failure(_, let error):
                                print("upload error: \(error)")
                                completion(success: false)
                            }
                        }
                    case .Failure(let error):
                        print("ERROR:\(error)")
                    }
            })
    }
    
    func interestedInMatch(match: MatchModel) {
        matchAction(false, match: match)
    }
    
    func notNowForMatch(match: MatchModel) {
        matchAction(true, match: match)
    }
    
    func matchAction(disliked:Bool, match: MatchModel) {
        let parameters = [
            "uID"       :   self.userProfile.uID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
            "mUID"      :   match.ID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
            "mType"     :   disliked == true ? "1" : "2",
            "uName"     :   self.userProfile.username.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        ]
        print("PARAMETERS FOR MATCH:\(parameters)")
        let URL = "\(fitMateServer.apiURL)addMeet.php".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        Alamofire.request(.GET, URL, parameters:parameters).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(_):
                print("success with data:\(data)")
                self.getMates({ (result, success) -> Void in
                    
                })
            case .Failure(_, let error):
                print("failed with error:\(error)")
            }
        }
    }
    
    func makeMatchModel(json: Dictionary<String, JSON>) -> MatchModel {
        let model: MatchModel = MatchModel(
            ID          :   json["uID"] != nil ? json["uID"]!.stringValue : "0",
            name        :   json["uName"]!.stringValue,
            firstName   :   json["uFirstName"]!.stringValue,
            lastName    :   json["uLastName"]!.stringValue,
            userName    :   json["uName"]!.stringValue,
            userTag     :   json["uTag"]!.stringValue,
            about       :   json["uAbout"]!.stringValue,
            gender      :   json["uGender"]!.intValue,
            birthday    :   json["uBirthday"]!.stringValue,
            age         :   ageFromBirthday(json["uBirthday"]!.stringValue),
            photo       :   json["uPhoto"]!.stringValue,
            device      :   json["uDevice"]!.stringValue,
            latitude    :   json["uLat"]!.doubleValue,
            longitude   :   json["uLog"]!.doubleValue,
            distance    :   json["distance"] != nil ? json["distance"]!.doubleValue : 0.0,
            email       :   json["uContactMail"]!.stringValue,
            categories  :   allCategories(json),
            galleryCount:   json["uGalleryCount"]!.intValue,
            gallery     :   gallery(json)
        )
        
        return model
    }
    
    func makeMateModel(json: Dictionary<String, JSON>) -> MateModel {
        let model: MateModel = MateModel(
            ID              :       json["uID"]!.stringValue,
            name            :       json["uName"]!.stringValue,
            firstName       :       json["uFirstName"]!.stringValue,
            lastName        :       json["uLastName"]!.stringValue,
            userName        :       json["uName"]!.stringValue,
            userTag         :       json["uTag"]!.stringValue,
            about           :       json["uAbout"]!.stringValue,
            gender          :       json["uGender"]!.intValue,
            birthday        :       json["uBirthday"]!.stringValue,
            age             :       ageFromBirthday(json["uBirthday"]!.stringValue),
            photo           :       json["uPhoto"]!.stringValue,
            device          :       json["uDevice"]!.stringValue,
            latitude        :       json["uLat"]!.doubleValue,
            longitude       :       json["uLog"]!.doubleValue,
            distance        :       json["distance"]!.doubleValue,
            email           :       json["uContactMail"]!.stringValue,
            categories      :       allCategories(json),
            galleryCount    :       json["uGalleryCount"]!.intValue,
            gallery         :       gallery(json),
            matchedDate     :       json["uMatchedDate"]!.stringValue,
            lastMessageFlag :       json["uMessageCheck"] != nil ? json["uMessageCheck"]!.intValue : 0,
            lastMessage     :       json["uMessage"] != nil ? json["uMessage"]!.stringValue : ""
        )
        
        return model
    }
    
    func gallery(json: Dictionary<String, JSON>) -> Array<UserImage> {
        var galleryArray = [UserImage]()
        for (var i: Int = 0; i < json["uGalleryCount"]!.intValue; i++) {
            let image: UserImage = userImageFromJson(json["gallery\(i)"]!.stringValue, gID: json["galleryID\(i)"]!.stringValue)
            galleryArray.append(image)
        }
        
        return galleryArray
    }
    
    func userImageFromJson(image: String, gID: String) -> UserImage {
        let image: UserImage = UserImage(gID: Int(gID)!, photo: image)
        return image
    }
    
    func allCategories(json: Dictionary<String, JSON>) -> Array<UserCategory> {
        var categoryArray = [UserCategory]()
        for (var i: Int = 0; i < json["uCategoryCount"]!.intValue; i++) {
            let category: UserCategory = categoryFromJson(json["category\(i)"]!.stringValue, cID: json["categoryID\(i)"]!.stringValue)
            categoryArray.append(category)
        }
        
        return categoryArray
    }
    
    func categoryFromJson(category: String, cID: String) -> UserCategory {
        let category: UserCategory = UserCategory(cID: Int(cID)!, name: category)
        return category
    }
    
    func ageFromBirthday(birthday: String) -> Int {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY"
        let currentYear: String = formatter.stringFromDate(NSDate())
        let birthYear = birthday.componentsSeparatedByString("-")[0]
        let age = Int(currentYear)! - Int(birthYear)!
        return age
    }
    
    func makeNewUser(completion: (result: Bool) -> Void) {
        //make a dictionary using the parameters from the User profile or empty strings if they do not exist.
        let paramsDict: Dictionary<String, String> = [
            "uID"           :   self.userProfile.uID == "NONE" ? "" : self.userProfile.uID,
            "uName"         :   self.userProfile.username == "NONE" ? "" : self.userProfile.username,
            "uFirstName"    :   self.userProfile.firstname == "NONE" ? "" : self.userProfile.firstname,
            "uLastName"     :   self.userProfile.lastname == "NONE" ? "" : self.userProfile.lastname,
            "uGender"       :   String(self.userProfile.gender),
            "uBirthday"     :   self.userProfile.birthday == "NONE" ? "" : self.userProfile.birthday,
            "uPhoto"        :   self.userProfile.photo == "NONE" ? "" : self.userProfile.photo,
            "uDevice"       :   self.userProfile.device == "NONE" ? "" : self.userProfile.device,
            "uLat"          :   String(self.userProfile.latitude),
            "uLog"          :   String(self.userProfile.longitude),
            "uContactMail"  :   self.userProfile.contactEmail == "NONE" ? "" : self.userProfile.contactEmail,
            "uTag"          :   self.userProfile.uTag == "NONE" ? "" : self.userProfile.uTag,
            "uAbout"        :   self.userProfile.uAbout == "NONE" ? "" : self.userProfile.uAbout,
            "cCount"        :   String(self.userProfile.categories.count),
        ]
        //Use the dictionary as the parameters to a POST request to signup.php at the apiURL.
        let rawURLString: String = "\(fitMateServer.apiURL)signup.php?";
        let URLString: String = rawURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        Alamofire.request(.POST, URLString, parameters: paramsDict).responseJSON { (request, response, data) in
            switch data {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
            case .Failure(_, let error):
                print("Request failed with error: \(error)")
            }
            completion(result: true)
        }
        
        //Completion closure:
        //Check the response for parameters. Any that are set in the response replace our existing parameters in the User profile.
    }

    func createNewUser() -> User {
        print("About to create new User.")
        var userProfile: User
        let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            context.processPendingChanges()
        }
        userProfile = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
        
        return userProfile

    }
    
    func getCurrentUser() -> User {
        var userProfile: User
        let fetch = NSFetchRequest(entityName: "User")
        print("about to set managed object context.")
        let context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        /*dispatch_async(dispatch_get_main_queue()) { () -> Void in
            context.processPendingChanges()
        }
        */
        print("About to fetch or create User.")
        do {
            let entities = try context.executeFetchRequest(fetch)
            if(entities.count > 0 && (entities[0] as! User).deleted == false) {
                userProfile = entities[0] as! User
            } else {
                userProfile = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
            }
        }
        catch _ {
            userProfile = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext) as! User
        }
        
        return userProfile
    }
    
    
    func updateUser(about: String, tagline: String) -> Void {
        print ("updating User...")
        let preformattedString : String = "\(fitMateServer.apiURL)updateProfile.php?uID=\(ProfileManager.sharedInstance.userProfile.uID)&uAbout=\(about)&uTag=\(tagline)"
        let urlString : String = preformattedString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        Alamofire.request(.GET, urlString, parameters: nil).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(_):
                print("Updated User.")
                print(data)
            case .Failure(_, let error) :
                print("Failed to update User with error: \(error)")
            }
        }
        
    }
    
    func saveUser() {
        do {
            try (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext.save()
        } catch {
            abort()
        }
    }
    
    func uploadUserCategories() {
        
    }
    
    
    func apiServerRequest(completion: (result: Bool, user: MatchModel?) -> Void) {
        let uID = self.userProfile.uID
        let paramsDict: Dictionary<String, String> = ["uID" : uID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!]
        let urlString = "\(fitMateServer.apiURL)getUserProfile.php?"
        Alamofire.request(.GET, urlString, parameters: paramsDict).responseJSON { (request, response, result) -> Void in
            //if let resultDict = result as! Dictionary {
            switch result {
            case .Success(let json):
                print("Success with JSON: \(json)")
                let jsonData = JSON(json)
                var userMatch: MatchModel?
                for (_, subJson) in jsonData {
                    let jsonDictionary = subJson.dictionaryValue
                    userMatch = self.makeMatchModel(jsonDictionary)
                }
                if userMatch != nil {
                    completion(result: true, user: userMatch)
                }
                
                self.bLoadUserProfileComplete = true
                
                return
            case .Failure(_, let error):
                print("Request failed with error: \(error)")
            }
            
            return
        }
        completion(result: false, user: nil)
    }
    
    
    func fbServerRequest() -> Bool {
        //make server request
        if(FBSDKAccessToken.currentAccessToken() != nil){
            let myFB = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id,name,email,first_name,last_name,gender,age_range,birthday"])
            
//            let accesstoken = FBSDKAccessToken.currentAccessToken() as! FBSDKAccessToken
//            print(accesstoken.tokenString)
            
            /*let photoFB = FBSDKGraphRequest(graphPath: "me/albums", parameters: nil)
            photoFB.startWithCompletionHandler { (connection, result, error) -> Void in
                if(error == nil) {
                    let user = result as? NSDictionary
                    let dataArray = user!["data"] as! NSArray
                    for (var i = 0; i < dataArray.count; i++){
//                        print(dataArray[i])
                        let dataInfo = dataArray[i] as? NSDictionary
                        if (dataInfo != nil){
                            let id:String = dataInfo!["id"] as! String
                            let requestString = "/\(id)/photos"
                            let realFB = FBSDKGraphRequest(graphPath: requestString, parameters: nil)
                            realFB.startWithCompletionHandler { (connection, result, error) -> Void in
                                if (error == nil){
                                    let photoData = result! as! NSDictionary
                                    let realData = photoData["data"] as! NSArray
                                    for (var i = 0; i < realData.count; i++){
                                        let individualData = realData[i] as! NSDictionary
                                        print(individualData)
                                        
                                        let idStr = individualData["id"] as! String
                                        let getPhotoFB = FBSDKGraphRequest(graphPath: idStr, parameters: nil)
                                        getPhotoFB.startWithCompletionHandler { (connection, result, error) -> Void in
                                            let data = result as! NSDictionary
                                            print(data)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }*/
            
            myFB.startWithCompletionHandler { (connection, result, error) -> Void in
                if(error == nil) {
                    print("No error.")
                    let user = result as? NSDictionary
                    if (user != nil){
                        print("RESULT: \(user)")
                        if let fbID = user!["id"] as? String {
                            self.createNewUser()
                            print("USER ID: \(fbID)")
                            self.userProfile.uID = fbID
                        }
                        //Make our user and save the data to Core Data

                        if let fbFirstName = user!["first_name"] as? String {
                            print("got first name of \(fbFirstName)")
                            self.userProfile.firstname = fbFirstName
                        }
                        if let fbLastName = user!["last_name"] as? String {
                            self.userProfile.lastname = fbLastName
                        }
                        if let fbEmail = user!["email"] as? String {
                            self.userProfile.contactEmail = fbEmail
                        }
                        if let fbGender = user!["gender"] as? String {
                            if fbGender == "male" {
                                self.userProfile.gender = 1
                            } else {
                                self.userProfile.gender = 0
                            }
                        }
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "yyyy"
                        let yearString = formatter.stringFromDate(NSDate())
                        
                        if let fbBirthday = user!["birthday"] as? String {
                            let birthdayComponents = fbBirthday.componentsSeparatedByString("/")
                            self.userProfile.birthday = "\(birthdayComponents[2])-\(birthdayComponents[0])-\(birthdayComponents[1])"
                            self.userProfile.age = Int16(yearString)! - Int16(birthdayComponents[2])!
                        } else {
                            self.userProfile.birthday = "1979-01-01"
                            self.userProfile.age = Int16(yearString)! - Int16("1979")!
                        }
                        if let fbName = user!["name"] as? String {
                            self.userProfile.username = fbName
                        }
                        let fbImageURL = "https://graph.facebook.com/\(self.userProfile.uID)/picture?type=large"
                        self.userProfile.photo = fbImageURL
                        
                        if (self.userProfile.gender == 1) {
                            self.userProfile.settingShowAgeMax = 100
                            self.userProfile.settingShowAgeMin = 18
                            self.userProfile.settingShowMeFlag = 2
                        } else {
                            self.userProfile.settingShowAgeMin = 18
                            self.userProfile.settingShowAgeMax = 100
                            self.userProfile.settingShowMeFlag = 2
                        }
                        
                        self.userProfile.uAbout = ""
                        if NSUserDefaults.standardUserDefaults().valueForKey("deviceToken") != nil {
                            let token = NSUserDefaults.standardUserDefaults().valueForKey("deviceToken")!
                            self.userProfile.device = "\(token as! String)"
                        }
                        
                        self.userProfile.settingDistance = 200
                        
                        if FitMateLocationManager.sharedInstance.haveLocation == true {
                            self.userProfile.latitude = FitMateLocationManager.sharedInstance.lastLocation!.latitude
                            self.userProfile.longitude = FitMateLocationManager.sharedInstance.lastLocation!.longitude
                        }
                        
                        self.saveUser()
                        
                        self.makeNewUser({ (result) -> Void in
                            self.apiServerRequest({ (result) -> Void in
                                print("Success?")
                            })
                        })

                    }
                } else {
                    print("ERROR: \(error)")
                }
            }
            return true
        }
        
        //use response to update Core Data model and NSUserDefaults
        
        return false
    }
    
    func getMates(completion: (result: [MateModel], success: Bool) -> Void) {
        let paramsDict: Dictionary<String, String> = [
            "uID"       :   self.userProfile.uID,
            "uLat"      :   String(self.userProfile.latitude),
            "uLog"      :   String(self.userProfile.longitude),
        ]
        let urlString : String = "\(fitMateServer.apiURL)getMates.php"
        Alamofire.request(.GET, urlString, parameters: paramsDict).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let JSONData) :
                var mateArray = [MateModel]()
                let json = JSON(JSONData)
                print("Success with JSON-getMates: \(json)")
                for (_, subJson) in json {
                    let match = subJson.dictionaryValue
                    if let flag = match["flag"] {
                        if flag == "2" {
                            print("No matches.")
                            let mateArray = [MateModel]()
                            completion(result: mateArray, success: true)
                            return
                        }
                    }
                    let mateModel: MateModel = self.makeMateModel(match)
                    //Avoid returning the current user.
                    if mateModel.ID != self.userProfile.uID {
                        mateArray.append(mateModel)
                    }
                }
                self.mates = mateArray
                self.updateMates()
                completion(result: mateArray, success: true)
             case .Failure(_, let error) :
                print("FAILED at \(request) with Error: \(error)")
                let mateArray = [MateModel]()
                completion(result: mateArray, success: false)
            }
        }
    }
    
    func matchForMate(mate: MateModel) -> MatchModel? {
        let searchID = mate.ID
        print("searchID: \(searchID)")
        if self.matches.count > 0 {
            for match in self.matches {
                if match.ID == searchID {
                    print("matchID:\(match.ID)")
                        print("returning match.")
                        return match
                }
            }
        }
        return nil
    }
    
    func updateMates() {
        print("User has \(self.mates.count) mates.")
        //Since we know that self.mates has real data in it now, we can also get messages and update those
        if NSUserDefaults.standardUserDefaults().valueForKey("mateCount") != nil {
            let oldCount = NSUserDefaults.standardUserDefaults().integerForKey("mateCount")
            let newCount = self.mates.count
            if newCount > oldCount {
                print("should be setting mates badge to \(newCount - oldCount).")
                self.setMatesBadge(newCount - oldCount)
            }
            NSUserDefaults.standardUserDefaults().setInteger(self.mates.count, forKey: "mateCount")
        } else {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "mateCount")
            print("should be setting mates badge to 1.")
            self.setMatesBadge(1)
        }
    }
    
    func updateActivities(activities: CategoryList) {
        self.clearActivities()
        var URLString = "\(fitMateServer.apiURL)changeCategory.php?cCount=\(activities.categories.count)&uID=\(self.userProfile.uID)"
        var counter = 0
        for activity in activities.categories {
            URLString.appendContentsOf("&category\(counter)=\(activity.name)&categoryID\(counter)=\(activity.cID)")
            counter++
            let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: self.mainContext) as! Category
            category.cID = activity.cID
            category.cName = activity.name
            category.cFlag = 1
            category.user = self.userProfile
        }
        let activityURL = URLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        Alamofire.request(.GET, activityURL).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let json):
                print("Updated categories with data:\(json)")
            case .Failure(_, let error):
                print("Failed to update categories with error:\(error)")
            }
        }
        self.saveUser()
    }
    
    
    func clearActivities() {
        let categoryContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        var categoryArray = []
        let categoryFetch = NSFetchRequest(entityName: "Category")
        do {
            categoryArray = try categoryContext.executeFetchRequest(categoryFetch)
        } catch {
            print("Unresolved Core Data Error in getActivities.")
        }
        for activity in categoryArray as! [Category] {
            categoryContext.deleteObject(activity)
        }
        self.saveUser()
    }
    
    func activities() -> CategoryList {
        let categoryContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        var categoryArray = []
        let categoryFetch = NSFetchRequest(entityName: "Category")
        do {
            categoryArray = try categoryContext.executeFetchRequest(categoryFetch)
        } catch {
            print("Unresolved Core Data Error in getActivities.")
        }
        var activityArray = [UserCategory]()
        for activity in categoryArray as! [Category] {
            let category = UserCategory(cID: activity.cID!.integerValue, name: activity.cName == nil ? "" : activity.cName!)
            activityArray.append(category)
        }
        let categoryList = CategoryList(categories:activityArray)
        return categoryList
    }
    
    func getSharedActivities(user: MatchModel) -> [UserCategory] {
        //Get local user's categories as a set
        //For each category ID of the remote user, check to see if it's in the set we've just made
        //Push all of that into an array and return it.
        let categoryNames = {(categories: [UserCategory]) -> [String] in
            var retval: [String] = []
            for cat in categories {
                retval.append(cat.name)
            }
            return retval
        }
        
        let userActivities = self.activities()
        let compareCategories = categoryNames(user.categories)
        var retval: [UserCategory] = []
        for activity in userActivities.categories {
            if compareCategories.contains(activity.name) {
                retval.append(activity)
            }
        }
        //let testCategory = UserCategory(cID: 2, name:"Running")
        return retval
    }
    
    func getSharedActivityNames(user: MatchModel) -> [String] {
        let categoryNames = {(categories: [UserCategory]) -> [String] in
            var retval: [String] = []
            for cat in categories {
                retval.append(cat.name)
            }
            return retval
        }
        
        let userActivities = self.activities()
        let compareCategories = categoryNames(user.categories)
        var retval: [String] = []
        for activity in userActivities.categories {
            if compareCategories.contains(activity.name) {
                retval.append(activity.name)
            }
        }
        return retval
    }
    
    func sharedActivitesFromCategories(categories: [UserCategory]) -> [String] {
        let categoryNames = {(categories: [UserCategory]) -> [String] in
            var retval: [String] = []
            for cat in categories {
                retval.append(cat.name)
            }
            return retval
        }
        
        let userActivities = self.activities()
        let compareCategories = categoryNames(categories)
        var retval: [String] = []
        for activity in userActivities.categories {
            if compareCategories.contains(activity.name) {
                retval.append(activity.name)
            }
        }
        return retval
    }
    
    func checkInbox() {
        let URLString = "\(fitMateServer.apiURL)checkBadge.php?uID=\(self.userProfile.uID)"
        Alamofire.request(.GET, URLString).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let jsonData):
                print("Success with JSON-CheckBadge: \(jsonData)")
                let json = JSON(jsonData)
                for (_, subJson) in json {
                    var badgeNumber: Int16 = 0
                    let badgeCount = subJson.dictionaryValue
                    if let matesCount = badgeCount["mates_badge"]?.int16Value {
                        badgeNumber += matesCount
                    }
                    if let messageCount = badgeCount["message_badge"]?.int16Value {
                        badgeNumber += messageCount
                    }
                    self.setMatesBadge(Int(badgeNumber))
                }
            case .Failure(_, let error):
                print("Failure with error: \(error)")
            }
        }
    }
    
    func sendMessage(recipient: String, message: String, completion: (result: Bool) -> Void) {
        let URLString = "\(fitMateServer.apiURL)sendMessage.php?uID=\(self.userProfile.uID)&touID=\(recipient.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)&uName=\(self.userProfile.firstname.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)&mText=\(message.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
        print(URLString)
        Alamofire.request(.GET, URLString).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let jsonData):
                print("Sent Message with response:\(jsonData)")
                completion(result: true)
            case .Failure(_, let error):
                print("failed to send message with error: \(error)")
            }
        }
    }
    
    func getConversation(partnerID: String, completion: (result: [JSQMessage], success: Bool) -> Void) {
        let URLString = "\(fitMateServer.apiURL)loadMessage.php?uID=\(self.userProfile.uID)&touID=\(partnerID.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)&uDevice=\(self.userProfile.device.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
        Alamofire.request(.GET, URLString).responseJSON { (request, response, data) -> Void in
            switch data {
            case .Success(let jsonData):
                print("Received Messages:\(jsonData)")
                var messages = [JSQMessage]()
                let json = JSON(jsonData)
                for (_, subJson) in json {
                    let message = subJson.dictionaryValue
                    let fitMateMessage = self.messageFromJson(message)
                    if (fitMateMessage != nil){
                        messages.append(fitMateMessage!)
                        print("MESSAGE:\(message)")
                    }
                }
                completion(result: messages, success: true)
            case .Failure(_, let error):
                print("failed to send message with error: \(error)")
                completion(result: [JSQMessage]() , success: false)
            }

        }
    }
    
    func messageFromJson(json: Dictionary<String, JSON>) -> JSQMessage? {
        var sender = ""
        var text = ""
        var fromSelf = ""
        var msgDate: NSDate?
        
        if let mID = json["uID"]?.stringValue {
            sender = mID
        }
        else {
            return nil
        }
        if let mText = json["mText"]?.stringValue {
            text = mText
        }
        else {
            return nil
        }
        if let from = json["message_from"]?.intValue {
            if from == 1 {
               fromSelf = "YES"
            }
        }
        else {
            return nil
        }
        if let time = json["mTime"]?.stringValue {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.dateFromString(time)
            if date != nil {
                let correctionInterval = NSTimeInterval.init(NSTimeZone.localTimeZone().secondsFromGMT)
                msgDate = date!.dateByAddingTimeInterval(correctionInterval)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
        let message = JSQMessage(senderId: sender, senderDisplayName: fromSelf, date: msgDate, text: text)
        //let message = JSQMessage(senderId: sender, displayName: fromSelf, text: text)
    
        return message
    }
    
    static func loadProfilePic(imageView: UIImageView, urlString: String)
    {
        Alamofire.request(.GET, urlString).validate().responseData({(request, response, data) in
            
            let realData: NSData? = data.value
            
            if realData == nil{
                imageView.image = UIImage(named: "unknown_photo")
            }
            else {
                imageView.image = UIImage(data: realData!)
            }
            
        })
    }
    
}