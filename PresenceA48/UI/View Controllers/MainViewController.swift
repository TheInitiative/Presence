//
//  MainViewController.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/3/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit
import Parse


class MainViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var usersTableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var baseButton: UIButton!
    var listButton: ListButton!
    var searchButton: SearchButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterLabel: UILabel!
    var listButtonTapCount: Int = 1
    
    @IBOutlet var mainView: MainView!

    var users: [PFUser] = []
    var searchedUsers: [PFUser] = []
    
    // properties to pass on to UserViewController
    var selectedCellName: String?
    var selectedCellStatus: String?
    var selectedCellImage: UIImage?
    
    
    // MARK: Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()

        // fetch all users from Parse
        reload(filter: .All)
        
    }
    
    func setup() {
        
        // user table view
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        // search bar settings
        searchBar.delegate = self
        
        // button creation
        listButton = ListButton(baseButton: baseButton, viewController: self)
        mainView.listButton = listButton
        
        searchButton = SearchButton(baseButton: baseButton, viewController: self)
        mainView.searchButton = searchButton
        
        // refresh control creation
        refreshControl = RefreshControl(viewController: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let nextViewController = segue.destinationViewController as? UserViewController {
            nextViewController.name = selectedCellName
            nextViewController.status = selectedCellStatus
            nextViewController.image = selectedCellImage
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool { return true }

    
    // MARK: - Actions
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        searchBar.resignFirstResponder()
        mainView.animateSearchBarExit()
        searchButton.selected = false
        
    }
    
    // MARK: --- Control button actions
    
    @IBAction func baseButtonTapped(sender: UIButton) {
        // base button togle
        
        if sender.selected {
            
            // deselect base button
            sender.selected = false
            mainView.hideCustomButtons()
        
        } else {
            
            // select base button
            sender.selected = true
            mainView.showCustomButtons()

        }
    }
    
    @IBAction func listButtonTapped(sender: UIButton) {
        
        switchFilter()
        
    }
    
    @IBAction func searchButtonTapped(sender: UIButton) {

        if sender.selected {
            // deactivate
            sender.selected = false
            mainView.animateSearchBarExit()
        } else {
            // activate
            sender.selected = true
            mainView.animateSearchBarEnter()
        }
        
    }
    
    // MARK: --- Filter functionality
    
    func switchFilter() {
        listButtonTapCount++
        
        switch listButtonTapCount {
        case 1:
            filterLabel.text = "ALL USERS"
            reload(filter: .All)
        case 2:
            filterLabel.text = "USERS INSIDE"
            reload(filter: .Inside)
        case 3:
            filterLabel.text = "USERS OUTSIDE"
            reload(filter: .Outside)
            listButtonTapCount = 0
        default:
            filterLabel.text = "ALL USERS"
        }
    }
    
    // MARK: --- Refresh functionality
    
    func refresh(sender: AnyObject) {
        reload(filter: .All)
    }
    
    func reload(filter filter: UserFilter) {
        ParseHelper.requestUsers(filter: filter) {
            (users, error) in
            
            if let users = users {
                self.users = users
                self.usersTableView.reloadData()
            }
            else { ErrorHanlding.displayError(self, error: error!) }
        }
        self.refreshControl.endRefreshing()
    }
}


// MARK: - Extensions

extension MainViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return users.count }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
        var userStatus: String?
        
        let cell = usersTableView.dequeueReusableCellWithIdentifier("UserCell") as! UserTableViewCell
        cell.nameLabel.text = user.username?.capitalizedString
        
        ParseHelper.requestUserStatus(user) { (status, error) -> () in
            
            if let status = status { userStatus = status }
            else
            {
                ErrorHanlding.displayError(self, error: error!)
                userStatus = "unavailable"
            }
            
            cell.statusLabel.text = userStatus!.capitalizedString
            
            if (userStatus != UserStatus.Outside.rawValue) {
                // user is inside
                cell.indicator.image = UIImage(named: "Indicator - Blue")
            } else {
                // user is outside
                cell.indicator.image = UIImage(named: "Indicator - Red")
            }
        }

        ParseHelper.requestUserProfilePicture(user) {
            (userProfilePicture, error) in
            
            if let profilePicture = userProfilePicture {
                cell.profilePicture.image = profilePicture
            }
            else { ErrorHanlding.displayError(self, error: error!) }
        }
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        usersTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell =  usersTableView.cellForRowAtIndexPath(indexPath) as! UserTableViewCell
        selectedCellName = cell.nameLabel.text?.capitalizedString
        selectedCellStatus = cell.statusLabel.text?.lowercaseString
        selectedCellImage = cell.profilePicture.image
        
        performSegueWithIdentifier("UserViewControllerSegue", sender: self)
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // restore original data
        ParseHelper.requestUsers(filter: nil) {
            (users, error) in
            
            if let users = users {
                self.users = users
                self.usersTableView.reloadData()
            }
            else { ErrorHanlding.displayError(self, error: error!) }
        }
        dismissKeyboard()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.characters.count > 0) {
            
            ParseHelper.searchUsersWithString(searchText, completion: { (users, error) -> Void in
                
                if let foundUsers = users {
                    self.users = foundUsers
                    self.usersTableView.reloadData()
                }
                else { ErrorHanlding.displayError(self, error: error!) }
            })
        } else {
            
            // restore original data
            ParseHelper.requestUsers(filter: nil) {
                (users, error) in
                
                if let users = users {
                    self.users = users
                    self.usersTableView.reloadData()
                }
                else { ErrorHanlding.displayError(self, error: error!) }
            }
        }
        
    }
}
