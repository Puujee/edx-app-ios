//
//  OEXStyles+Swift.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 25/05/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import Foundation
import UIKit

extension OEXStyles {
    
    var navigationTitleTextStyle : OEXTextStyle {
        return OEXTextStyle(weight: .SemiBold, size: .Base, color : navigationItemTintColor())
    }
    
    var navigationButtonTextStyle : OEXTextStyle {
        return OEXTextStyle(weight: .SemiBold, size: .Small)
    }
    
    public func applyGlobalAppearance() {
        
        if (OEXConfig.sharedConfig().shouldEnableNewCourseNavigation()) {
            //Probably want to set the tintColor of UIWindow but it didn't seem necessary right now
            
            UINavigationBar.appearance().barTintColor = navigationBarColor()
            UINavigationBar.appearance().tintColor = navigationItemTintColor()
            if UIDevice.currentDevice().isOSVersionAtLeast8() {
                UINavigationBar.appearance().translucent = false
            }
            UINavigationBar.appearance().titleTextAttributes = navigationTitleTextStyle.attributes
            UIBarButtonItem.appearance().setTitleTextAttributes(navigationButtonTextStyle.attributes, forState: .Normal)
            
            UIToolbar.appearance().tintColor = navigationBarColor()
            
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        }
        
        
    }
}