//
//  UserTableViewCell.swift
//  PresenceA48
//
//  Created by Adrian Wisaksana on 10/3/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell
{

    // MARK: - Properties
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var indicator: UIImageView!
    
    // MARK: - Methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // round imageView
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.masksToBounds = true
        
        // set selection color for cell
        let blueColorView = UIView()
        blueColorView.backgroundColor = UIColor(red: 72/255, green: 178/255, blue: 232/255, alpha: 1.0)
        selectedBackgroundView = blueColorView
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
