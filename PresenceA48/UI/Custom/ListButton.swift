//
//  SearchButton.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 11/6/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit

class ListButton: UIButton {
    
    init(baseButton: UIButton, viewController: MainViewController) {
        super.init(frame: baseButton.frame)
        
        self.center = baseButton.center
        self.setBackgroundImage(UIImage(named: "List Button"), forState: UIControlState.Normal)
        self.addTarget(viewController, action: "listButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.hidden = true
        
        viewController.mainView.insertSubview(self, atIndex: 4)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

}
