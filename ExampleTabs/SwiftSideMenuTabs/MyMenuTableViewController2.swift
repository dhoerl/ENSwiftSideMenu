//
//  MyMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

final class MyMenuTableViewController: UITableViewController, ENSideMenuReference {
	weak var sideMenu: ENSideMenu?  // ENSideMenuReference
    var selectedMenuItem = NSIndexPath(forRow: 0, inSection: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRowAtIndexPath(selectedMenuItem, animated: false, scrollPosition: .Middle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func selectTableIndex(index: NSIndexPath)  {
		selectedMenuItem = index
		tableView.selectRowAtIndexPath(selectedMenuItem, animated: false, scrollPosition: .Middle)
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        cell!.textLabel?.text = "ViewController #\(indexPath.row+1)"
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let
			sideMenu = sideMenu,
			sideMenuController = sideMenu.sourceViewController as? ENSideMenuProtocol,
			tabBarController = sideMenu.sourceViewController as? UITabBarController,
			viewControllers = tabBarController.viewControllers where viewControllers.count > indexPath.row
		else { print("FUCKED"); return }

        print("did select row: \(indexPath.row)")
        
        if (indexPath.row == selectedMenuItem) {
print("Screwed! \(indexPath.row) \(selectedMenuItem)")
            return
        }
        
        selectedMenuItem = indexPath
        
        //Present new view controller
        //let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
		//destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController1")

        let destViewController = viewControllers[indexPath.row]
		sideMenuController.setContentViewController(destViewController)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
