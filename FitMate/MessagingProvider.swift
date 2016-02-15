//
//  MessagingProvider.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/10/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class MessagingProvider {
    let manager = ProfileManager.sharedInstance
    //decide on a message storage method and store an array of it as a variable
    
    func messagesForUser(mate: MateModel, completion: (result: [JSQMessage], success: Bool) -> Void) {
        manager.getConversation(mate.ID) { (result, success) -> Void in
            completion(result: result, success: success)
        }
        //use loadMessage.php with mate and the local user
    }
    
   /* func test(mate: MateModel) {
        self.sendMessage(mate, message: "Hey Derek!!!")
    }
*/
    
    func sendMessage(recipient: MateModel, message: String, completion: (result: Bool) -> Void) -> Bool {
        manager.sendMessage(recipient.ID, message: message) { (result) -> Void in
            completion(result: result)
        }
        return true
        //send a message to recipient using sendMessage.php
    }
    
    func saveMessages(mate: MateModel){
        //saves the current user's messages to persistent storage
    }
}