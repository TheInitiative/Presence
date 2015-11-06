//
//  RefreshControl.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 11/6/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit

class RefreshControl: UIRefreshControl {

    init(viewController: MainViewController) {
        super.init()
        
        self.attributedTitle = NSAttributedString(string: "Pull to refresh")
        addTarget(viewController, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        viewController.usersTableView.addSubview(self)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}
