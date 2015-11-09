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
typealias RequestUserProfilePictureCallback = (image: UIImage?, error: NSError?) -> Void


class ParseHelper
{
    static let ParseUserClassName = "_User"

    static func requestUsers(filter filter: UserFilter?, completionBlock: (users: [PFUser]?, error: NSError?) -> Void)
    {
        
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
            
            if let users = objects as? [PFUser] {
                completionBlock(users: users, error: nil)
            }
            else { completionBlock(users: nil, error: error) }
        }
    }
    
    static func requestUserStatus(user: PFUser, onComplete: (status: String?, error: NSError?)-> () )
    {
        let userQuery = PFQuery(className: ParseUserClassName)
        userQuery.whereKeyExists("status")
        userQuery.findObjectsInBackgroundWithBlock { (response, error) -> Void in
            
            if let status = response?.first
            {
                let castStatus = status.valueForKey("status") as! String
                onComplete(status: castStatus, error: nil)
            }
            else { onComplete(status: nil, error: error) }
        }
    }
    // get user profile picture
    
    static func getDataFromUrl(url: NSURL, completionBlock: GetDataFromURLCallback)
    {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url)
        { (data, response, error) in
            
            if let picture = data { completionBlock(data: picture, response: response, error: error) }
            else { completionBlock(data: nil, response: nil, error: error) }
        }
        task.resume()
    }
    
    static func requestUserProfilePicture(user: PFUser, completion: RequestUserProfilePictureCallback)
    {
        let urlPath = user.valueForKey("picture") as! String
        
        if let url = NSURL(string: urlPath)
        {
            getDataFromUrl(url)
            { (data, response, error) in
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else { completion(image: nil, error: error); return } // GUARD is probably not the best thing to use here...
                    let image = UIImage(data: data)
                    completion(image: image, error: nil)
                }
            }
        }
    }
    
    static func searchUsersWithString(string: String, completion: (users: [PFUser]?, error: NSError?) -> Void)
    {
        let query = PFQuery(className: ParseUserClassName)
        
        query.whereKey("username", containsString: string.lowercaseString)
        
        query.findObjectsInBackgroundWithBlock()
        { (results, error) in
            
            if let userResults = results as? [PFUser] { completion(users: userResults, error: nil) }
            else { completion(users: nil, error: error) }
        }
    }
}