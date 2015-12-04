//
//  FirstViewController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 11/22/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit

//class FirstViewController: UIViewController {
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

class FirstViewController: UIViewController, ENSideMenuControl {
    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.title = "First"
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

    @IBAction func toggleSideMenu(sender: AnyObject) {
        toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
}

