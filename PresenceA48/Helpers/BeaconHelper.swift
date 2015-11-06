//
//  BeaconHelper.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/10/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import Foundation


class BeaconHelper {
    
    static let Squirt = "SQUIRT"
    static let Pika = "PIKA"
    static let Mud = "MUD"
    static let Mew2 = "MEW2"
    static let Tree = "TREE"
    static let Bulb = "BULB"
    
    static var beaconsInRange: [String: Bool] = [
        UserStatus.Entrance.rawValue: false,
        UserStatus.FirstFloor.rawValue: false,
        UserStatus.Lounge.rawValue: false,
        UserStatus.StaffArea.rawValue: false,
        UserStatus.StaffLounge.rawValue: false,
        UserStatus.Basement.rawValue: false
    ]
    
    static func setTrueWithStatus(status: UserStatus) {
        
        beaconsInRange[status.rawValue] = true
        
    }
    
    static func setFalseWithStatus(status: UserStatus) {
        
        beaconsInRange[status.rawValue] = false
        
    }
    
    static func checkIfOutside() -> Bool {
        
        var outsideCount = 0
        for inRegion in beaconsInRange.values {
            if !inRegion {
                outsideCount++
            }
        }
        
        if outsideCount == 6 { return true }
        else { return false }
    
    }
}