//
//  SearchBar.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 11/6/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit

class SearchBar: UISearchBar {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // search bar UI settings
        let searchIconImage = UIImage(named: "Search Icon - White")
        self.setImage(searchIconImage, forSearchBarIcon: .Search, state: .Normal)
        self.imageForSearchBarIcon(.Clear, state: .Normal)
        self.tintColor = UIColor(red: 72/255, green: 178/255, blue: 232/255, alpha: 1)
        self.backgroundColor = UIColor.whiteColor()
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.1
        
        // search bar text field UI settings
        let searchTextField = self.valueForKey("_searchField") as! UITextField
        searchTextField.font = UIFont(name: "HelveticaNeue-Light", size: 21)
        searchTextField.textColor = UIColor.grayColor()
    }

}
