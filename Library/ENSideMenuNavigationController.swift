//
//  ENSideMenuNavigationController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014-2015 Evgeny Nazarov. All rights reserved.
//  Copyright (c) 2015 David Hoerl. All rights reserved.
//

import UIKit

var enSideMenuOwners: [ENSideMenuOwners] = [.NavigationController]

class ENSideMenuNavigationController: UINavigationController, ENSideMenuProtocol {
	var sideMenu : ENSideMenu?
	var sideMenuAnimationType : ENSideMenuAnimation = .Default

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Navigation
	func setContentViewController(contentViewController: UIViewController) {
print("setContentViewController")
		self.sideMenu?.toggleMenu()

		switch sideMenuAnimationType {
		case .None:
			self.viewControllers = [contentViewController]
		default:
			//contentViewController.navigationItem.hidesBackButton = true
			self.setViewControllers([contentViewController], animated: true)
		}		
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		guard let sideMenu = sideMenu else { return }
		sideMenu.updateFrame()
	}
}
