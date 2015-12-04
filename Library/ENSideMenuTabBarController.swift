//
//  ENSideMenuTabBarController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 11/25/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit


var enSideMenuOwners: [ENSideMenuOwners] = [.TabBarController]

class ENSideMenuTabBarController: UITabBarController, UITabBarControllerDelegate, ENSideMenuProtocol {
    var sideMenu : ENSideMenu?

    override func viewDidLoad() {
        super.viewDidLoad()

//        if let sideMenuControl = selectedViewController as? ENSideMenuControl {
//			sideMenuControl.sideMenu = sideMenu
//		}
view.backgroundColor = UIColor.redColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		guard let sideMenu = sideMenu else { return }
		sideMenu.updateFrame()
	}

    // MARK: - Navigation
    func setContentViewController(contentViewController: UIViewController) {
		guard let
			myViewControllers = viewControllers
			//,
			//sideMenu = sideMenu
			//currentViewController = selectedViewController as? ENSideMenuProtocol
		else { return }

//print("setContentViewController")

		for (index, viewController) in myViewControllers.enumerate() {
			if viewController === contentViewController {
				print("HAH - found it!!! index = \(index)")
				if index == selectedIndex { return }
				selectedIndex = index
				break
			}
		}
    }

	// Primary source for this: https://www.reddit.com/r/swift/comments/2fc1ze/animated_switch_when_using_tabbarcontroller/
	// Secondary discussions on SO:
	//    http://stackoverflow.com/a/23440338/1633251 (references the post below)
	//    http://stackoverflow.com/a/5180104/1633251 [ first answer ]
	func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		guard let sideMenu = sideMenu where sideMenu.isMenuOpen == true else { return nil }

		let duration: NSTimeInterval = 1.0
		let foo = TransitioningObject(duration: duration)
		foo.fromViewC = fromVC
		foo.toViewC = toVC

		if let controller = controlViewController() {
			controller.hideSideMenuView(true, duration: duration)
			return foo
		}
		else {
			return nil
		}
	}
}

final class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
	let duration: NSTimeInterval
	var fromViewC: UIViewController!
	var toViewC: UIViewController!
	//weak var tvc: UITabBarController?

	//var fromSideMenuViewC: ENSideMenuControl?

	init(duration: NSTimeInterval) {
		self.duration = duration
		super.init()
	}

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		guard let
				fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
				toView = transitionContext.viewForKey(UITransitionContextToViewKey),
				containerView = transitionContext.containerView()
		else { fatalError("TransitionContext broken") }

        // Get the "from" and "to" views

		containerView.addSubview(fromView)
        containerView.addSubview(toView)

        //The "to" view with start "off screen" and slide left pushing the "from" view "off screen"

#if false
		// Looks hokey
        toView.frame = CGRectMake(toView.frame.width, 0, toView.frame.width, toView.frame.height)
        let fromNewFrame = CGRectMake(-1 * fromView.frame.width, 0, fromView.frame.width, fromView.frame.height)
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            toView.frame = CGRectMake(0, 0, toView.frame.width, toView.frame.height)
            fromView.frame = fromNewFrame
        }) { (Bool) -> Void in
            // update internal view - must always be called
            transitionContext.completeTransition(true)
        }
#else
		// TransitionFlipFromLeft CrossDissolve
		UIView.transitionFromView(fromView, toView: toView, duration: duration,
		options: [.TransitionCrossDissolve, .ShowHideTransitionViews, .AllowAnimatedContent],
		completion: { (Bool) -> Void in
            transitionContext.completeTransition(true)
			assert(fromView.alpha > 0.99)
			assert(toView.alpha > 0.99)
		})
#endif
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }

	func animationEnded(transitionCompleted: Bool) {
		// the transitionFromView animation does this
		fromViewC.view.hidden = false
	}
}

