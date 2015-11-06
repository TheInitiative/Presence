//
//  AppDelegate.swift
//  PresenceA48
//

import UIKit
import Parse
import ParseUI
import FBSDKCoreKit
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {
    
    var window: UIWindow?
    var overlay : UIView?
    var parseLoginHelper: ParseLoginHelper!
    
    // Make beacon manager
    let beaconManager = ESTBeaconManager()
    let proximityUUID: NSUUID = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
    
    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {
            [unowned self] user, error in
            
            // Initialize the ParseLoginHelper with a callback
            if let _ = user {
                // if login was successful, display the TabBarController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")

                self.window?.rootViewController!.presentViewController(tabBarController, animated:true, completion:nil)
            }
            else if let err = error { ErrorHanlding.displayError((self.window?.inputViewController)!, error: err) }
        }
    }
    
    func setUpNotificationObservers() {
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "changed:",
            name: "",
            object: nil
        )
        
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Estimote
        ESTConfig.setupAppID("presence-gu1", andAppToken: "c4d68516cad8ce2f29631f02c19848b3")
        
        // Set delegate and request authorization
        
        // beaconDelegate = BeaconDelegate()
        // self.beaconManager.delegate = beaconDelegate
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        // Setup the beacons
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 27443, minor: 13447, identifier: BeaconHelper.Squirt))
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 58650, minor: 21135, identifier:  BeaconHelper.Bulb))
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 1516, minor: 28192, identifier: BeaconHelper.Pika))
        
        // PARSE
        
        // User notifs
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        )

        Parse.enableLocalDatastore()
        
        // Initialize Parse
        Parse.setApplicationId("Mmww5Ksu7tBqAStSU7BGYKJV5wz9iYDiSRPXiA0A",
            clientKey: "RmBTXWD3kQtUaUyAXlZHM7UoEmrQZPP8RWwDZB73")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let user = PFUser.currentUser()

        var startViewController = UIViewController()
        
        if (user != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
        } else {
            let loginViewController = PFLogInViewController()
            loginViewController.fields = PFLogInFields.Facebook
            loginViewController.delegate = parseLoginHelper
            loginViewController.facebookPermissions = ["email","public_profile"]
            
            startViewController = loginViewController
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController
        self.window?.makeKeyAndVisible()
        
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!) {
        
        if let user = PFUser.currentUser() {
            let notification = UILocalNotification()
            
            let statusKey = "status"
            
            switch region.identifier {
            case BeaconHelper.Squirt:
                user[statusKey] = UserStatus.RegionA.rawValue
                notification.alertBody = "You entered the Squirtle Region"
                BeaconHelper.setTrueWithStatus(UserStatus.RegionA)
            case BeaconHelper.Bulb:
                user[statusKey] = UserStatus.RegionB.rawValue
                notification.alertBody = "You entered the Bulbasaur Region"
                BeaconHelper.setTrueWithStatus(UserStatus.RegionB)
            case BeaconHelper.Pika:
                user[statusKey] = UserStatus.RegionC.rawValue
                notification.alertBody = "You entered the Pikachu Region"
                BeaconHelper.setTrueWithStatus(UserStatus.RegionC)
            default:
                user[statusKey] = UserStatus.Error.rawValue
                notification.alertBody = "Error identifying beacon/Person entered"
            }
            
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let err = error { ErrorHanlding.displayError((self.window?.inputViewController)!, error: err) }
            })
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
        }
    }
    
    func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!) {
        
        if let user = PFUser.currentUser() {
            let notification = UILocalNotification()
            
            switch region.identifier {
            case BeaconHelper.Squirt:
                notification.alertBody = "You left the Squirtle region"
                BeaconHelper.setFalseWithStatus(UserStatus.RegionA)
            case BeaconHelper.Bulb:
                notification.alertBody = "You left the Bulbasaur region"
                BeaconHelper.setFalseWithStatus(UserStatus.RegionB)
            case BeaconHelper.Pika:
                notification.alertBody = "You left the Pikachu region"
                BeaconHelper.setFalseWithStatus(UserStatus.RegionC)
            default:
                user["status"] = UserStatus.Error.rawValue
                notification.alertBody = "Error identifying beacon/Person left"
            }
            
            user.saveInBackgroundWithBlock({
                (success, error) -> Void in
                if let err = error { ErrorHanlding.displayError((self.window?.inputViewController)!, error: err) }
            })
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    

}

extension AppDelegate: PFLogInViewControllerDelegate {  }