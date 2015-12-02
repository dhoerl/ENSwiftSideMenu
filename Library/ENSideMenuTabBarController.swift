//
//  ENSideMenuTabBarController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 11/25/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit

class ENSideMenuTabBarController: UITabBarController, ENSideMenuProtocol {
    var sideMenu : ENSideMenu?
    var sideMenuAnimationType : ENSideMenuAnimation = .Default
	
    override func viewDidLoad() {
        super.viewDidLoad()

        if let sideMenuControl = selectedViewController as? ENSideMenuControl {
			sideMenuControl.sideMenu = sideMenu
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    func setContentViewController(contentViewController: UIViewController) {
		guard let
			myViewControllers = viewControllers
			//currentViewController = selectedViewController as? ENSideMenuProtocol
		else { return }

print("setContentViewController")

		for (index, viewController) in myViewControllers.enumerate() {
			if viewController === contentViewController {
				print("HAH - found it!!! index = \(index)")
				if index == selectedIndex { return }
				selectedIndex = index
				break
			}
		}

        self.sideMenu?.toggleMenu()

        switch sideMenuAnimationType {
        case .None:
            self.viewControllers = [contentViewController]
        default:
            contentViewController.navigationItem.hidesBackButton = true
            self.setViewControllers([contentViewController], animated: true)
        }        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
