//
//  MainViewController.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/3/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit
import Parse


class MainViewController: UIViewController
{
    // MARK: Properties
    
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var baseButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    var listButton: UIButton!
    var searchButton: UIButton!
    
    var selectedCellName: String?
    var selectedCellStatus: String?
    var selectedCellImage: UIImage?

    var users: [PFUser] = []
    
    // MARK: Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setup()
        
        // reload
        ParseHelper.requestUsers()
        { (users, error) in
            if let users = users
            {
                self.users = users
                self.usersTableView.reloadData()
            }
        }
        
    }
    
    func setup()
    {
        // user table view
        usersTableView.delegate = self
        usersTableView.dataSource = self

        usersTableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0)
        usersTableView.backgroundView?.backgroundColor = UIColor.purpleColor()
        
        // button settings and initiation
        let buttonFrame = baseButton.frame
        let buttonCenter = baseButton.center
        
        listButton = UIButton(frame: buttonFrame)
        listButton.frame = buttonFrame
        listButton.center = buttonCenter
        listButton.setBackgroundImage(UIImage(named: "List Button"), forState: UIControlState.Normal)
        listButton.addTarget(self, action: "listButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        listButton.hidden = true
        
        searchButton = UIButton(frame: buttonFrame)
        searchButton.center = buttonCenter
        searchButton.setBackgroundImage(UIImage(named: "Search Button"), forState: UIControlState.Normal)
        searchButton.addTarget(self, action: "searchButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        searchButton.hidden = true
        let selectedSearchButtonImage = UIImage(named: "Search Button - Selected")
        searchButton.setImage(selectedSearchButtonImage, forState: .Selected)
        
        self.view.insertSubview(self.searchButton, atIndex: 3)
        self.view.insertSubview(self.listButton, atIndex: 4)
        
        // search bar settings
        searchBar.delegate = self
        
        let searchIconImage = UIImage(named: "Search Icon - White")
        searchBar.setImage(searchIconImage, forSearchBarIcon: .Search, state: .Normal)
        searchBar.imageForSearchBarIcon(.Clear, state: .Normal)
        searchBar.tintColor = UIColor(red: 72/255, green: 178/255, blue: 232/255, alpha: 1)
        searchBar.backgroundColor = UIColor.whiteColor()

        searchBar.layer.shadowColor = UIColor.blackColor().CGColor
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBar.layer.shadowOpacity = 0.1
        
        let searchTextField = searchBar.valueForKey("_searchField") as! UITextField
        searchTextField.font = UIFont(name: "HelveticaNeue-Light", size: 21)
        searchTextField.textColor = UIColor.grayColor()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let nextViewController = segue.destinationViewController as! UserViewController
        nextViewController.name = selectedCellName!
        nextViewController.status = selectedCellStatus!
        nextViewController.image = selectedCellImage!
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func prefersStatusBarHidden() -> Bool { return true }

    
    // MARK: - Actions
    
    // search bar animations
    func animateSearchBarEnter()
    {
        searchBar.becomeFirstResponder()
        UIView.animateWithDuration(0.5, animations:
            {
                self.searchBarTopConstraint.constant = 0
                self.view.layoutIfNeeded()
        })
    }
    
    func animateSearchBarExit()
    {
        searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.5, animations:
            {
                self.searchBarTopConstraint.constant = -64
                self.view.layoutIfNeeded()
        })
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
        searchBar.resignFirstResponder()
        animateSearchBarExit()
        searchButton.selected = false
        
    }
    
    @IBAction func baseButtonTapped(sender: UIButton)
    {
        // base button togle
        let buttonMargin: CGFloat = 66
        
        if sender.selected
        {
            // deselect base button
            sender.selected = false
            UIView.animateWithDuration(0.13, animations:
            {
                self.searchButton.center = CGPointMake(self.searchButton.center.x + buttonMargin, self.baseButton.center.y)
            },
            completion:
            { void in
                    UIView.animateWithDuration(0.2,
                        animations:
                        {
                            self.listButton.center = CGPointMake(self.listButton.center.x + buttonMargin, self.baseButton.center.y)
                            self.searchButton.center = CGPointMake(self.searchButton.center.x + buttonMargin, self.baseButton.center.y)
                        },
                        completion:
                        { void in
                            self.listButton.hidden = true
                            self.searchButton.hidden = true
                    })
            })
        
        }
        else
        {
            // select base button
            sender.selected = true
            UIView.animateWithDuration(0.1,
                animations:
                {
                self.listButton.hidden = false
                self.searchButton.hidden = false
                self.listButton.center = CGPointMake(self.baseButton.center.x - buttonMargin, self.baseButton.center.y)
                self.searchButton.center = CGPointMake(self.baseButton.center.x - buttonMargin, self.baseButton.center.y)
                },
                completion:
                { void in
                    UIView.animateWithDuration(0.1,
                        animations:
                        {
                            self.searchButton.center = CGPointMake(self.searchButton.center.x - buttonMargin, self.baseButton.center.y)
                        })
            })
        }
    }
    
    @IBAction func listButtonTapped(sender: UIButton)
    {
        
        // apply filtering code here
        
    }
    
    @IBAction func searchButtonTapped(sender: UIButton)
    {

        if sender.selected
        {
            // deactivate
            sender.selected = false
            animateSearchBarExit()
        } else
        {
            // activate
            sender.selected = true
            animateSearchBarEnter()
        }
        
    }

}

// MARK: - Extensions

extension MainViewController: UITableViewDataSource
{
    
    // set number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return users.count
    }
    
    // access rows at index path
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = usersTableView.dequeueReusableCellWithIdentifier("UserCell") as! UserTableViewCell
        
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.username
        
        let userStatus = ParseHelper.requestUserStatus(user)
        cell.statusLabel.text = userStatus
        
        let userProfilePic = ParseHelper.requestUserProfilePicture(user)
        if let userProfilePic = userProfilePic
        {
            cell.profilePicture.image = userProfilePic
        }
        
        return cell
    }
    
}

extension MainViewController: UITableViewDelegate
{
    // set row height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 77
    }
    
    
    // on row selection 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // deselect row
        usersTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell =  usersTableView.cellForRowAtIndexPath(indexPath) as! UserTableViewCell
        selectedCellName = cell.nameLabel.text
        selectedCellStatus = cell.statusLabel.text
        selectedCellImage = cell.profilePicture.image
        
        performSegueWithIdentifier("UserViewControllerSegue", sender: self)
    }
}

extension MainViewController: UISearchBarDelegate
{
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        dismissKeyboard()
    }
}
