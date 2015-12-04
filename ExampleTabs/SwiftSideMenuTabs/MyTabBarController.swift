//
//  MyTabBarController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 11/23/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit


final class MyTabBarController: ENSideMenuTabBarController {
	private lazy var myMenuTableViewController: MyMenuTableViewController = { MyMenuTableViewController() }()

    override func viewDidLoad() {
print("HAHAHAH")
		//sideMenu = ENSideMenu(sourceViewController: self, menuViewController: MyMenuTableViewController())
        sideMenu = ENSideMenu(sourceViewController: self, menuViewController: myMenuTableViewController, menuPosition:.Left)
		if let sideMenu = sideMenu {
			//sideMenu.sideMenuController = self
			//sideMenu.delegate = self //optional
			sideMenu.menuWidth = 180.0 // optional, default is 160
			//sideMenu?.bouncingEnabled = false
			//sideMenu.containerViewIsSecond = true
		}
        
        // make navigation bar showing over side menu
        //view.bringSubviewToFront(tabBar)

        super.viewDidLoad()

		delegate = self

		for v in view.subviews {
			print("SV: \(Mirror(reflecting: v).subjectType)", v.frame)
		}
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		print("Tabber will \(selectedIndex)")
	}
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		print("MyTabBarController \(selectedIndex)")

//		var v: UIView! = selectedViewController?.view
//		while v != nil {
//			print("View: \(Mirror(reflecting: v).subjectType)")
//			v = v.superview
//		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
		//print("DID SELECT TAB BAR")
		let index = NSIndexPath(forRow: selectedIndex, inSection: 0)
		myMenuTableViewController.selectTableIndex(index)
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