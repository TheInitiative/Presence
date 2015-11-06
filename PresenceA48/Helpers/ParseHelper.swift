//
//  ParseHelper.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/8/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import Foundation
import Parse
import FBSDKCoreKit

typealias GetDataFromURLCallback = (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void
typealias RequestUserProfilePictureCallback = (image: UIImage?) -> Void


class ParseHelper {
    
    static let ParseUserClassName = "_User"

    static func requestUsers(filter filter: UserFilter?, completionBlock: (users: [PFUser]?, error: NSError?) -> Void) {
        
        let query = PFQuery(className: ParseUserClassName)
        
        if let filter = filter {
            switch filter {
            case .All:
                break
            case .Inside:
                query.whereKey("status", notEqualTo: "outside")
            case .Outside:
                query.whereKey("status", equalTo: "outside")
            }
        }

        query.findObjectsInBackgroundWithBlock() { (objects, error) in
            
            if (error != nil) {
                print(error?.description)
            }
            
            if let users = objects as? [PFUser] {
                completionBlock(users: users, error: nil)
            }
        }
        
    }
    
    static func requestUserStatus(user: PFUser) -> String {
        
        if let userStatus = user.valueForKey("status") as? String {
            return userStatus
        } else {
            return "Error fetching data"
        }
        
    } 
    
    // get user profile picture
    
    static func getDataFromUrl(url: NSURL, completionBlock: GetDataFromURLCallback) {
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            
            completionBlock(data: data, response: response, error: error)
        }
        
        task.resume()
        
    }
    
    static func requestUserProfilePicture(user: PFUser, completion: RequestUserProfilePictureCallback) {
        
        let urlPath = user.valueForKey("picture") as! String
        
        if let url = NSURL(string: urlPath) {
            
            getDataFromUrl(url) {
                (data, response, error) in
                
                if let error = error {
                    print(error.description)
                }
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { return }
                    let image = UIImage(data: data)
                    completion(image: image)
                }
            }
            
        }
    
    }
    
    static func searchUsersWithString(string: String, completion: (users: [PFUser]) -> Void) {
        
        let query = PFQuery(className: ParseUserClassName)
        
        query.whereKey("username", containsString: string.lowercaseString)
        
        query.findObjectsInBackgroundWithBlock() {
            (results, error) in
            
            if let error = error {
                print(error.description)
            }
            
            if let userResults = results as? [PFUser] {
                completion(users: userResults)
            }
            
        }
        
    }
    
}