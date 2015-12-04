//
//  MyNavigationController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 30.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

final class MyNavigationController: ENSideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceViewController: self, menuViewController: MyMenuTableViewController(), menuPosition:.Left)
		if let sideMenu = sideMenu {
			//sideMenu.sideMenuController = self
			//sideMenu.delegate = self //optional
			sideMenu.menuWidth = 180.0 // optional, default is 160
			//sideMenu?.bouncingEnabled = false
			sideMenu.containerViewIsSecond = true // default value, set to false to have the slide in menu on top of everything
		}
        
        // make navigation bar showing over side menu
    }

	override func viewDidLayoutSubviews() {
		print("NAV CONT viewDidLayoutSubviews")
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
