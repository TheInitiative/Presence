//
//  UserViewController.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/3/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit

class UserViewController: UIViewController
{

    // MARK: - Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var indicator: UIImageView!
    
    var name: String?
    var status: String?
    var image: UIImage?
    
    // MARK: - Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setup()
        
        // label setup source view controller
        self.nameLabel.text = name!
        self.statusMessageLabel.text = status!
        self.profilePicture.image = image!
    }
    
    func setup()
    {
        // rounded imageView
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped(sender: UIButton)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
