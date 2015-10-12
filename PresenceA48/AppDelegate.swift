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
            selector: "changedLocation:",
            name: "",
            object: nil)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // ESTIMOTE
        
        ESTConfig.setupAppID("presence-a48", andAppToken: "1f15bfbc76eb65f76fc96ffdef4eb7e8")
        
        // Set delegate and request authorization
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        // Setup the beacons!
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 21397, minor: 49589, identifier: "Blueberry"))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 13815, minor: 51968, identifier:  "Mint"))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 16123, minor: 35119, identifier: "Icy1"))
        
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: proximityUUID, major: 18550, minor: 58637, identifier: "Icy2"))
        
        
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
    
    // Beacon manager function belongs here?
    
    func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!)
    {
        if let user = PFUser.currentUser()
        {
            let notification = UILocalNotification()
            // setup internat nsnotivication center to alert a function, push to parse based on the region
            switch region.identifier
            {
            case "Blueberry":
                user["status"] = "Upstairs"
                notification.alertBody = "You entered Upstairs!"
                
            case "Mint":
                user["status"] = "Staff area"
                notification.alertBody = "You entered Staff area!"
                
            case "Icy1":
                user["status"] = "Downstairs"
                notification.alertBody = "You entered Downstairs!"
                
            case "Icy2":
                user["status"] = "Main room"
                notification.alertBody = "You entered Main room!"
                
            default:
                user["status"] = "We broke: Gigantic error occured"
                notification.alertBody = "Error identifying beacon/Person left"
            }
            
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let err = error { ErrorHanlding.displayError((self.window?.inputViewController)!, error: err) }
            })
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
        }
    }
    
    func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!) {
        if let user = PFUser.currentUser()
        {
            let notification = UILocalNotification()
            user["status"] = "Outside"
            notification.alertBody = "You left " + String(region)
            
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let err = error { ErrorHanlding.displayError((self.window?.inputViewController)!, error: err) }
            })
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