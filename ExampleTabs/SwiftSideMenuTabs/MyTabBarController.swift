//
//  MyTabBarController.swift
//  SwiftSideMenuTabs
//
//  Created by David Hoerl on 11/23/15.
//  Copyright © 2015 dhoerl. All rights reserved.
//

import UIKit


final class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

		delegate = self
        // Do any additional setup after loading the view.
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

		let foo = TransitioningObject()
		foo.fromViewC = fromVC
		foo.toViewC = toVC

//print("fromVC \(fromVC)")
		if let
			navCont = fromVC as? UINavigationController,
			topView = navCont.topViewController as? ENSideMenuControl
		{
print("HIDE IT!")
			topView.hideSideMenuView(true)
		}

		print("2 HAHAHAHHAHA")
		return foo
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
	var fromViewC: UIViewController!
	var toViewC: UIViewController!

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Get the "from" and "to" views
        let fromView : UIView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView : UIView = transitionContext.viewForKey(UITransitionContextToViewKey)!

        transitionContext.containerView()!.addSubview(fromView)
        transitionContext.containerView()!.addSubview(toView)

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
print("Transition From View...")
		// TransitionFlipFromLeft CrossDissolve
		UIView.transitionFromView(fromView, toView: toView, duration: 1.0,
		options: [.TransitionCrossDissolve, .ShowHideTransitionViews, .AllowAnimatedContent],
		completion: { (Bool) -> Void in
            transitionContext.completeTransition(true)
		})
#endif
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }
}
