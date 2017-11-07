//
//  AppDelegate.swift
//  Randogo
//
//  Created by Sergiy Momot on 6/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Kingfisher
import PINCache
import PopupDialog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CategoriesDataSource.load()
        
        ImageCache.default.maxMemoryCost = 32 * 1024 * 1024
        ImageCache.default.maxDiskCacheSize = 64 * 1024 * 1024
        ImageCache.default.maxCachePeriodInSecond = 28 * 24 * 3600
        
        PINCache.shared().diskCache.byteLimit = 16 * 1024 * 1024
        PINCache.shared().diskCache.ageLimit = 24 * 3600
        PINCache.shared().memoryCache.costLimit = 8 * 1024 * 1024
        let _ = PINCache.shared().object(forKey: "fake")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()

        let style = PopupDialogDefaultView.appearance()
        style.backgroundColor = UIColor.flatLightTeal
        style.titleFont = UIFont(name: "AvenirNext-Demibold", size: 24.0)!
        style.titleColor = UIColor.white
        style.messageFont = UIFont(name: "AvenirNext-Regular", size: 18.0)!
        style.messageColor = UIColor.white
        
        let buttonStyle = DefaultButton.appearance()
        buttonStyle.buttonColor = UIColor.flatDarkTeal
        buttonStyle.titleColor = UIColor.white
        buttonStyle.titleFont = UIFont(name: "AvenirNext-Demibold", size: 20.0)!
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
}

