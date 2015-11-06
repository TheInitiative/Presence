//
//  ErrorHandling.swift
//  PresenceA48
//
//  Created by mbp_13 on 03/10/15.
//  Copyright © 2015 Quinn Baker. All rights reserved.
//

import Foundation
import UIKit

class ErrorHanlding
{
    static func displayError(controller: UIViewController, error: NSError)
    {
        let alertController = UIAlertController(
            title: "Error",
            message: error.description,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
}