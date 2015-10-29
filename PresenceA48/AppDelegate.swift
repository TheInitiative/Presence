//
//  AppDelegate.swift
//  PresenceA48
//

import UIKit
import Parse
import ParseUI
import FBSDKCoreKit
import ParseFacebookUtilsV4
//import EstimoteSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate
{
    var window: UIWindow?
    var overlay : UIView?
    var parseLoginHelper: ParseLoginHelper!
    
    // Make beacon manager
    
    let beaconManager = ESTBeaconManager()
    let proximityUUID: NSUUID = NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
    
    override init()
    {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            // Initialize the ParseLoginHelper with a callback
            if let _ = user
            {
                // if login was successful, display the TabBarController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")

                self.window?.rootViewController!.presentViewController(tabBarController, animated:true, completion:nil)
            }
            else if let err = error { ErrorHanlding.displayError((self.window?.inputViewController)!, error: err) }
        }
    }
    
    func setUpNotificationObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "changed:",
            name: "",
            object: nil)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // ESTIMOTE
        
        ESTConfig.setupAppID("presence-gu1", andAppToken: "c4d68516cad8ce2f29631f02c19848b3")
        
        // Set delegate and request authorization
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        // Setup the beacons!
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 27443, minor: 13447, identifier: BeaconHelper.Squirt))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 58650, minor: 21135, identifier:  BeaconHelper.Bulb))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 1516, minor: 28192, identifier: BeaconHelper.Pika))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 15846, minor: 43468, identifier: BeaconHelper.Mud))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 5659, minor: 27278, identifier: BeaconHelper.Tree))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 7348, minor: 43372, identifier: BeaconHelper.Mew2))
        
        // PARSE
        
        // User notifs
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: .Alert, categories: nil))

        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("Mmww5Ksu7tBqAStSU7BGYKJV5wz9iYDiSRPXiA0A",
            clientKey: "RmBTXWD3kQtUaUyAXlZHM7UoEmrQZPP8RWwDZB73")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let user = PFUser.currentUser()

        var startViewController = UIViewController()
        
        if (user != nil)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
            
        }
        else
        {
            let loginViewController = PFLogInViewController()
            loginViewController.fields = PFLogInFields.Facebook
            loginViewController.delegate = parseLoginHelper
            loginViewController.facebookPermissions = ["email","public_profile"]
            
            // TODO:
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
    
    func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!)
    {
        if let user = PFUser.currentUser()
        {
            let notification = UILocalNotification()
            
            let statusKey = "status"
            switch region.identifier
            {
            case BeaconHelper.Squirt:
                user[statusKey] = UserStatus.Entrance.rawValue
                notification.alertBody = "You entered Entrance"
                BeaconHelper.setTrueWithStatus(UserStatus.Entrance)
            case BeaconHelper.Bulb:
                user[statusKey] = UserStatus.FirstFloor.rawValue
                notification.alertBody = "You entered First Floor"
                BeaconHelper.setTrueWithStatus(UserStatus.FirstFloor)
            case BeaconHelper.Pika:
                user[statusKey] = UserStatus.Lounge.rawValue
                notification.alertBody = "You entered Lounge"
                BeaconHelper.setTrueWithStatus(UserStatus.Lounge)
            case BeaconHelper.Mud:
                user[statusKey] = UserStatus.StaffArea.rawValue
                notification.alertBody = "You entered Staff Area"
                BeaconHelper.setTrueWithStatus(UserStatus.StaffArea)
            case BeaconHelper.Tree:
                user[statusKey] = UserStatus.Basement.rawValue
                notification.alertBody = "You entered Basement"
                BeaconHelper.setTrueWithStatus(UserStatus.Basement)
            case BeaconHelper.Mew2:
                user[statusKey] = UserStatus.StaffLounge.rawValue
                notification.alertBody = "You entered Staff Lounge!"
                BeaconHelper.setTrueWithStatus(UserStatus.StaffLounge)
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
    
    func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!)
    {
        if let user = PFUser.currentUser()
        {
            let notification = UILocalNotification()
            
            switch region.identifier
            {
            case BeaconHelper.Squirt:
                notification.alertBody = "You left Entrance"
                BeaconHelper.setFalseWithStatus(UserStatus.Entrance)
            case BeaconHelper.Bulb:
                notification.alertBody = "You left First Floor"
                BeaconHelper.setFalseWithStatus(UserStatus.FirstFloor)
            case BeaconHelper.Pika:
                notification.alertBody = "You left Lounge"
                BeaconHelper.setFalseWithStatus(UserStatus.Lounge)
            case BeaconHelper.Mud:
                notification.alertBody = "You left Staff Area"
                BeaconHelper.setFalseWithStatus(UserStatus.StaffArea)
            case BeaconHelper.Tree:
                notification.alertBody = "You left Basement"
                BeaconHelper.setFalseWithStatus(UserStatus.Basement)
            case BeaconHelper.Mew2:
                notification.alertBody = "You left Staff Lounge!"
                BeaconHelper.setFalseWithStatus(UserStatus.StaffLounge)
            default:
                user["status"] = UserStatus.Error.rawValue
                notification.alertBody = "Error identifying beacon/Person left"
            }
            
            if BeaconHelper.checkIfOutside()
            {
                user["status"] = UserStatus.Outside.rawValue
                notification.alertBody = ""
            }
            
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let err = error { ErrorHanlding.displayError((self.window?.inputViewController)!, error: err) }
            })
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: PFLogInViewControllerDelegate {}