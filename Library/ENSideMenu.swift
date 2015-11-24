//
//  SideMenu.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 24.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

@objc protocol ENSideMenuDelegate {
    optional func sideMenuWillOpen()
    optional func sideMenuWillClose()
    optional func sideMenuDidOpen()
    optional func sideMenuDidClose()
    optional func sideMenuShouldOpenSideMenu () -> Bool
}

@objc protocol ENSideMenuProtocol {
    var sideMenu : ENSideMenu? { get }
    func setContentViewController(contentViewController: UIViewController)
}

public enum ENSideMenuAnimation : Int {
    case None, Default
}

/**
The position of the side view on the screen.

- Left:  Left side of the screen
- Right: Right side of the screen
*/
enum ENSideMenuPosition : Int {
    case Left, Right
}

//@objc
protocol ENSideMenuControl {
	func toggleSideMenuView ()
	func hideSideMenuView (forceNoBounce: Bool, duration: NSTimeInterval)
	func showSideMenuView (forceNoBounce: Bool, duration: NSTimeInterval)
	func isSideMenuOpen () -> Bool
	func fixSideMenuSize()
	func sideMenuController () -> ENSideMenuProtocol?
}
extension ENSideMenuControl {
    /**
    Changes current state of side menu view.
    */
    func toggleSideMenuView () {
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    /**
    Hides the side menu view.
    */
    func hideSideMenuView (forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
        sideMenuController()?.sideMenu?.hideSideMenu(forceNoBounce, duration: duration)
    }
    /**
    Shows the side menu view.
    */
    func showSideMenuView (forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
        sideMenuController()?.sideMenu?.showSideMenu(forceNoBounce, duration: duration)
    }
    
    /**
    Returns a Boolean value indicating whether the side menu is showed.

    :returns: BOOL value
    */
    func isSideMenuOpen () -> Bool {
        guard let
			sideMenuController = self.sideMenuController(),
			sideMenu = sideMenuController.sideMenu
		else { return false }

        return sideMenu.isMenuOpen
    }
    
    /**
     * You must call this method from viewDidLayoutSubviews in your content view controlers so it fixes size and position of the side menu when the screen
     * rotates.
     * A convenient way to do it might be creating a subclass of UIViewController that does precisely that and then subclassing your view controllers from it.
     */
    func fixSideMenuSize() {
		guard let viewController = self as? UIViewController else { return }

        if let navController = viewController.navigationController as? ENSideMenuNavigationController {
            navController.sideMenu?.updateFrame()
        }
    }

    /**
    Returns a view controller containing a side menu

    :returns: A `UIViewController`responding to `ENSideMenuProtocol` protocol
    */
    func sideMenuController () -> ENSideMenuProtocol? {
		guard
			let viewController = self as? UIViewController,
			var parentViewController = viewController.parentViewController
		else { return topMostController() }

		repeat {
            if let parentViewController = parentViewController as? ENSideMenuProtocol {
                return parentViewController
			}
			if let newParentViewController = parentViewController.parentViewController {
				assert(newParentViewController != parentViewController)
				parentViewController = newParentViewController
			}
			else {
				return nil
			}
		} while true
    }

    private func topMostController () -> ENSideMenuProtocol? {
        guard var topController: UIViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
		else { return nil }

		if let
			tabBarController = topController as? UITabBarController,
			selectedViewController = tabBarController.selectedViewController
		{
			topController = selectedViewController
		}

        while let presentedViewController = topController.presentedViewController where presentedViewController is ENSideMenuProtocol {
            topController = presentedViewController
        }
        
        return topController as? ENSideMenuProtocol
    }
}

final class ENSideMenu : NSObject, UIGestureRecognizerDelegate {
    var menuWidth : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
            updateFrame()
        }
    }
    private var menuPosition = ENSideMenuPosition.Left
    ///  A Boolean value indicating whether the bouncing effect is enabled. The default value is TRUE.
    var bouncingEnabled = true
    /// The duration of the slide animation. Used only when `bouncingEnabled` is FALSE.
    var animationDuration: NSTimeInterval = 0.40
	/// The elasticity of the slide animation
	var elasticity: CGFloat = 0.20
	/// Magnitude of the "push"
	var magnitude: CGFloat = 5

    /// The delegate of the side menu
    weak var delegate : ENSideMenuDelegate?
    /// A Boolean value indicating whether the left swipe is enabled.
    var allowLeftSwipe = true
    /// A Boolean value indicating whether the right swipe is enabled.
    var allowRightSwipe = true
    
    private(set) var menuViewController : UIViewController!
    private(set) var isMenuOpen = false

	private let sideMenuContainerView =  UIView()
    private var animator : UIDynamicAnimator
    private var sourceView : UIView!
    private var needUpdateApperance = false


    /**
    Initializes an instance of a `ENSideMenu` object.
    
    :param: sourceView   The parent view of the side menu view.
    :param: menuPosition The position of the side menu view.
    
    :returns: An initialized `ENSideMenu` object, added to the specified view.
    */
    init(sourceView: UIView, menuPosition: ENSideMenuPosition) {
        self.sourceView = sourceView
        self.menuPosition = menuPosition

        animator = UIDynamicAnimator(referenceView:sourceView)

		super.init()

        self.setupMenuView()
        animator.delegate = self

        // Add right swipe gesture recognizer
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer.delegate = self
        
        if menuPosition == .Left {
            sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sideMenuContainerView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
        else {
            sideMenuContainerView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
		sideMenuContainerView.hidden = true
    }
    /**
    Initializes an instance of a `ENSideMenu` object.
    
    :param: sourceView         The parent view of the side menu view.
    :param: menuViewController A menu view controller object which will be placed in the side menu view.
    :param: menuPosition       The position of the side menu view.
    
    :returns: An initialized `ENSideMenu` object, added to the specified view, containing the specified menu view controller.
    */
    convenience init(sourceView: UIView, menuViewController: UIViewController, menuPosition: ENSideMenuPosition) {
        self.init(sourceView: sourceView, menuPosition: menuPosition)
        self.menuViewController = menuViewController
        self.menuViewController.view.frame = sideMenuContainerView.bounds
        self.menuViewController.view.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        sideMenuContainerView.addSubview(self.menuViewController.view)
    }

    /**
    Updates the frame of the side menu view.
    */
    private func updateFrame() {
        let size = sourceView.frame.size
        let menuFrame = CGRectMake(
            (menuPosition == .Left) ?
                isMenuOpen ? 0 : -menuWidth-1.0 :
                isMenuOpen ? size.width - menuWidth : size.width+1.0,
            sourceView.frame.origin.y,
            menuWidth,
            size.height
        )
        sideMenuContainerView.frame = menuFrame
    }

    private func setupMenuView() {
        updateFrame() // Configure side menu container

        sideMenuContainerView.backgroundColor = UIColor.clearColor()
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false
        sideMenuContainerView.layer.shadowOffset = (menuPosition == .Left) ? CGSizeMake(1.0, 1.0) : CGSizeMake(-1.0, -1.0)
        sideMenuContainerView.layer.shadowRadius = 1.0
        sideMenuContainerView.layer.shadowOpacity = 0.125
        sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
        
        sourceView.addSubview(sideMenuContainerView)
        
		// Add blur view
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
		visualEffectView.frame = sideMenuContainerView.bounds
		visualEffectView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		sideMenuContainerView.addSubview(visualEffectView)
    }
    
    private func toggleMenuShouldOpen (shouldOpen: Bool, forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
        if shouldOpen && delegate?.sideMenuShouldOpenSideMenu?() == false {
            return
        }

        updateSideMenuApperanceIfNeeded()

		if shouldOpen {
			sideMenuContainerView.hidden = false
		}

        isMenuOpen = shouldOpen
        let size = sourceView.frame.size
        if forceNoBounce == false && bouncingEnabled == true {
            animator.removeAllBehaviors()
            
            var gravityDirectionX: CGFloat
            var pushMagnitude: CGFloat
            var boundaryPointX: CGFloat
            var boundaryPointY: CGFloat
            
            if menuPosition == .Left {
                // Left side menu
                gravityDirectionX = (shouldOpen) ? 1 : -1
                pushMagnitude = (shouldOpen) ? 20 : -20
                boundaryPointX = (shouldOpen) ? menuWidth : -menuWidth-2
                boundaryPointY = 20
            }
            else {
                // Right side menu
                gravityDirectionX = (shouldOpen) ? -1 : 1
                pushMagnitude = (shouldOpen) ? -20 : 20
                boundaryPointX = (shouldOpen) ? size.width-menuWidth : size.width+menuWidth+2
                boundaryPointY =  -20
            }
            
            let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
            gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX,  0)
			gravityBehavior.magnitude = magnitude
            animator.addBehavior(gravityBehavior)
            
            let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
            collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryPointX, boundaryPointY),
                toPoint: CGPointMake(boundaryPointX, size.height))
            animator.addBehavior(collisionBehavior)
            
            let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehaviorMode.Instantaneous)
            pushBehavior.magnitude = pushMagnitude
            animator.addBehavior(pushBehavior)
            
            let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuContainerView])
            menuViewBehavior.elasticity = elasticity
            animator.addBehavior(menuViewBehavior)
        }
        else {
            var destFrame :CGRect
            if menuPosition == .Left {
                destFrame = CGRectMake(shouldOpen ? -2.0 : -menuWidth, 0, menuWidth, size.height)
            }
            else {
                destFrame = CGRectMake(shouldOpen ? size.width-menuWidth : size.width+2.0, 0, menuWidth, size.height)
            }

            UIView.animateWithDuration(
                duration > 0 ? duration : animationDuration,
                animations: { () -> Void in
                    self.sideMenuContainerView.frame = destFrame
                },
                completion: { (Bool) -> Void in
					if self.isMenuOpen {
						self.delegate?.sideMenuDidOpen?()
					} else {
						self.sideMenuContainerView.hidden = true
						self.delegate?.sideMenuDidClose?()
					}
            })
        }

		if shouldOpen {
			delegate?.sideMenuWillOpen?()
		} else {
			delegate?.sideMenuWillClose?()
		}
    }

	// MAKR: - Gesture Recognizer 

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let swipeGestureRecognizer = gestureRecognizer as? UISwipeGestureRecognizer else { return false }

		if !allowLeftSwipe && swipeGestureRecognizer.direction == .Left {
			return false
		}
		if !allowRightSwipe && swipeGestureRecognizer.direction == .Right {
			return false
		}
		if isMenuOpen == false {
			sideMenuContainerView.hidden = false
		}

        return true
    }

    func handleGesture(gesture: UISwipeGestureRecognizer) {
        toggleMenuShouldOpen((self.menuPosition == .Right && gesture.direction == .Left) || (self.menuPosition == .Left && gesture.direction == .Right))
    }

	// MARK: - Other Private

    private func updateSideMenuApperanceIfNeeded () {
		guard needUpdateApperance == true else { return }

		var frame = sideMenuContainerView.frame
		frame.size.width = menuWidth
		sideMenuContainerView.frame = frame
		sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath

		needUpdateApperance = false
    }

	// MARK: - Public

    /**
    Toggles the state of the side menu.
    */
    func toggleMenu () {
        if isMenuOpen {
            toggleMenuShouldOpen(false)
        }
        else {
            updateSideMenuApperanceIfNeeded()
            toggleMenuShouldOpen(true)
        }
    }
    /**
    Shows the side menu if the menu is hidden.
    */
    func showSideMenu (forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
        if !isMenuOpen {
            toggleMenuShouldOpen(true, forceNoBounce: forceNoBounce, duration: duration)
        }
    }
    /**
    Hides the side menu if the menu is showed.
    */
    func hideSideMenu (forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
        if isMenuOpen {
            toggleMenuShouldOpen(false, forceNoBounce: forceNoBounce, duration: duration)
        }
    }
}
extension ENSideMenu: UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
		if self.isMenuOpen {
			self.delegate?.sideMenuDidOpen?()
		} else {
			self.sideMenuContainerView.hidden = true
			self.delegate?.sideMenuDidClose?()
		}
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
#if DEBUG
        print("resume")
#endif
    }
}
