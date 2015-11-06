//
//  MainView.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 11/6/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit

class MainView: UIView {

    // MARK: Properties
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var baseButton: UIButton!
    var searchButton: SearchButton!
    var listButton: ListButton!
    let buttonMargin: CGFloat = 66
    
    
    // MARK: Base method(s)
    
    override func awakeFromNib() {
        
        // user table view UI setting
        usersTableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0)
        
    }
    
    
    // MARK: Animations
    
    func animateSearchBarEnter() {
        
        searchBar.becomeFirstResponder()
        UIView.animateWithDuration(0.5) {
            self.filterLabel.layer.opacity = 0
            self.searchBarTopConstraint.constant = 0
            self.layoutIfNeeded()
        }
        
    }
    
    func animateSearchBarExit() {
        
        searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.5) {
            self.filterLabel.layer.opacity = 1
            self.searchBarTopConstraint.constant = -64
            self.layoutIfNeeded()
        }
        
    }
    
    func hideCustomButtons() {
        
        UIView.animateWithDuration(0.13, animations: {
            self.searchButton.center = CGPointMake(self.searchButton.center.x + self.buttonMargin, self.baseButton.center.y)
            },
            completion: {
                (void) in
                
                UIView.animateWithDuration(0.2,
                    animations: {
                        self.listButton.center = CGPointMake(self.listButton.center.x + self.buttonMargin, self.baseButton.center.y)
                        self.searchButton.center = CGPointMake(self.searchButton.center.x + self.buttonMargin, self.baseButton.center.y)
                    },
                    completion: {
                        (void) in
                        
                        self.listButton.hidden = true
                        self.searchButton.hidden = true
                })
        })
        
    }
    
    func showCustomButtons() {
        
        UIView.animateWithDuration(0.1,
            animations: {
                self.listButton.hidden = false
                self.searchButton.hidden = false
                self.listButton.center = CGPointMake(self.baseButton.center.x - self.buttonMargin, self.baseButton.center.y)
                self.searchButton.center = CGPointMake(self.baseButton.center.x - self.buttonMargin, self.baseButton.center.y)
            },
            completion: {
                (void) in
                
                UIView.animateWithDuration(0.1) {
                    self.searchButton.center = CGPointMake(self.searchButton.center.x - self.buttonMargin, self.baseButton.center.y)
                }
        })
    }
    
    

}
