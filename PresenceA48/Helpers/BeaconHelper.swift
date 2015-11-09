//
//  BeaconHelper.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/10/15.
//  Copyright © 2015 Adrian Wisaksana. All rights reserved.
//

import Foundation
import Parse


class BeaconHelper {
    
    static let Squirt = "SQUIRT"
    static let Pika = "PIKA"
    static let Bulb = "BULB"
    
    static var beaconsInRange: [String: Bool] =
        [
            UserStatus.RegionA.rawValue: false,
            UserStatus.RegionB.rawValue: false,
            UserStatus.RegionC.rawValue: false,
        ]
    {
        didSet {
            if isOutside() {
                let notification = UILocalNotification()
                if let user = PFUser.currentUser() {
                    user["status"] = UserStatus.Outside.rawValue
                    
                    notification.alertBody = "You left the regions"
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                    
                    user.saveInBackground()
                }
            }
        }
    }
    
    static func setTrueWithStatus(status: UserStatus) {
        
        beaconsInRange[status.rawValue] = true
        
    }
    
    static func setFalseWithStatus(status: UserStatus) {
        
        beaconsInRange[status.rawValue] = false
        
    }
    
    static func isOutside() -> Bool {
        
        var outsideCount = 0
        for inRegion in beaconsInRange.values {
            if !inRegion {
                outsideCount++
            }
        }
        
        if outsideCount == 3 { return true }
        else { return false }
    
    }
}