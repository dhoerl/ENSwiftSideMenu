//
//  RootNavigationViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

class ENSideMenuNavigationController: UINavigationController, ENSideMenuProtocol {
    var sideMenu : ENSideMenu?
    var sideMenuAnimationType : ENSideMenuAnimation = .Default

//    init( menuViewController: UIViewController, contentViewController: UIViewController?) {
//        super.init(nibName: nil, bundle: nil)
//        
//        if let contentViewController = contentViewController{
//            self.viewControllers = [contentViewController]
//        }
//
//        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: menuViewController, menuPosition:.Left)
//        view.bringSubviewToFront(navigationBar)
//    }

//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

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
}
