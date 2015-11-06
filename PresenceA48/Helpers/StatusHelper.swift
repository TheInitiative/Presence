//
//  StatusHelper.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/17/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import Foundation

enum UserStatus: String {
    
    case RegionA = "region a"
    case RegionB = "region b"
    case RegionC = "region c"
    case Outside = "outside"
    case Error = "error"
    
}

enum UserFilter {
    
    case All
    case Inside
    case Outside
    
}

