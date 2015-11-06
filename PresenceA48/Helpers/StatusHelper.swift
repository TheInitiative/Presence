//
//  StatusHelper.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/17/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import Foundation

enum UserStatus: String {
    
    case Entrance = "entrance"
    case FirstFloor = "first floor"
    case StaffArea = "staff area"
    case Lounge = "lounge"
    case Basement = "basement"
    case StaffLounge = "staff lounge"
    case Outside = "outside"
    case Error = "error"
    
}

enum UserFilter {
    
    case All
    case Inside
    case Outside
    
}

