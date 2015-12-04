//
//  MyNavigationController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 12/4/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	override func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
		// This is suppressed because the Tab Bar Controller sends this message on every tab switch, and we don't want anything changed in our app.
		//STLog(@"popToRootViewControllerAnimated");
		return [UIViewController]() // Array<UIViewController>()
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
