//
//  MyTabBarController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 11/23/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit


final class MyTabBarController: ENSideMenuTabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
		self.sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MyMenuTableViewController())

        super.viewDidLoad()

		delegate = self
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		print("Tabber will \(selectedIndex)")

		if let viewController = selectedViewController as? ENSideMenuProtocol {
			if viewController.sideMenu == nil {

			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//	func tabBarController(tabBarController: UITabBarController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
//		print("1 HAHAHAHHAHA")
//		return TransitioningObject() as? UIViewControllerInteractiveTransitioning
//	}

	func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let duration: NSTimeInterval = 1.0
		let foo = TransitioningObject(duration: duration)
		foo.fromViewC = fromVC
		foo.toViewC = toVC

		var fromSideMenuViewC: ENSideMenuControl?
		if let sideMenuControl = fromVC as? ENSideMenuControl {
			fromSideMenuViewC = sideMenuControl
		} else
		if let
			navCont = fromVC as? UINavigationController,
			sideMenuControl = navCont.topViewController as? ENSideMenuControl
		{
			fromSideMenuViewC = sideMenuControl
		}

		if let fromSideMenuViewC = fromSideMenuViewC {
			foo.fromSideMenuViewC = fromSideMenuViewC
			fromSideMenuViewC.hideSideMenuView(true, duration: duration)
		}

		print("2 HAHAHAHHAHA")
		return foo
	}

	func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
		print("DID SELECT TAB BAR")
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

final class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
	let duration: NSTimeInterval
	var fromViewC: UIViewController!
	var toViewC: UIViewController!
	var fromSideMenuViewC: ENSideMenuControl?

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
		})
#endif
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }

	func animationEnded(transitionCompleted: Bool) {
		guard let fromViewC = fromViewC as? ENSideMenuProtocol else { return }

		if transitionCompleted {
print("RELEASE SIDE MENU")
			fromViewC.sideMenu = nil
		}
	}
}
