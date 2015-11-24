//
//  SecondViewController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 11/22/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit

//class SecondViewController: UIViewController {
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		// Do any additional setup after loading the view, typically from a nib.
//	}
//
//	override func didReceiveMemoryWarning() {
//		super.didReceiveMemoryWarning()
//		// Dispose of any resources that can be recreated.
//	}
//
//
//}
//

class ViewController2: UIViewController, ENSideMenuDelegate, ENSideMenuControl {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Move next line to viewWillAppear functon if you store your view controllers

		navigationItem.title = "Second"

        self.sideMenuController()?.sideMenu?.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		print("Will Appear")
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		//print("Will Disappear: coord = ", self.transitionCoordinator())
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
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
