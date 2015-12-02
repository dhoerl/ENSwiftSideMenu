//
//  SideMenu.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 24.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit


enum ENSideMenuOwners: Int {
	//case MySelf=1, PresentingViewController, ParentViewController, NavigationController, SplitViewController, TabBarController, RootViewController
	case MySelf=1, NavigationController, SplitViewController, TabBarController
}
// Set this to some other option set to select how we find the ENSideMenu
var enSideMenuOwners: [ENSideMenuOwners] = [.NavigationController, .TabBarController]

// MARK: - ENSideMenuDelegate

// Conformed to by the controlling class as well as any UIViewController that wants to get messaged
protocol ENSideMenuDelegate : class {
    func sideMenuWillOpen()
    func sideMenuWillClose()
    func sideMenuDidOpen()
    func sideMenuDidClose()

	// Adopters should override the default function. ENSideMenuProtocol agent relays to appropriate UIViewController
    func sideMenuShouldOpenSideMenu () -> Bool
}
extension ENSideMenuDelegate {
    func sideMenuWillOpen() { }
    func sideMenuWillClose() { }
    func sideMenuDidOpen() { }
    func sideMenuDidClose() { }

    func sideMenuShouldOpenSideMenu () -> Bool { print("ASKED IF SHOULD"); return true }	// defaults to "works all the time"
}

// The entity that knows how to change the current view controller
//   Typically a container view: Navigation Controller, TabBar Controller, etc
protocol ENSideMenuProtocol : class, ENSideMenuDelegate {
    var sideMenu : ENSideMenu? { get set }	// set so we the one sideMenu instance can be moved from one controller to another
    func setContentViewController(contentViewController: UIViewController)

	func visibleViewController() -> ENSideMenuDelegate?
}
extension ENSideMenuProtocol {
	func visibleViewController() -> ENSideMenuDelegate? {
		print("visibleViewController")

		var viewController: UIViewController?
		switch self {
		case let vc as UINavigationController:
			if vc.viewControllers.count == 1 {
				viewController = vc.visibleViewController
			}
		case let vc as UISplitViewController:
			if vc.viewControllers.count == 2 {
				viewController = vc.viewControllers[1]	// detail controller
			}
		case let vc as UITabBarController:
			viewController = vc.selectedViewController

		case let vc as UIViewController:	// Must be last, all others would go into this case
			viewController = vc

		default:
			fatalError("Missing Code")
		}

		if let viewController = viewController where viewController.presentedViewController == nil {
			return viewController as? ENSideMenuDelegate
		}
		else {
			return nil
		}
	}

	func sideMenuShouldOpenSideMenu() -> Bool {
print("ASK DELEGTATE if OK TO OPEN")
		if let sideMenuDelegate = visibleViewController() {
			return sideMenuDelegate.sideMenuShouldOpenSideMenu()
		}
		else {
			return false
		}
	}
}

protocol ENSideMenuReference : class {
    weak var sideMenu : ENSideMenu? { get set }
}

enum ENSideMenuAnimation : Int {
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

// MARK: - ENSideMenuControl

protocol ENSideMenuControl : ENSideMenuDelegate {
	// Action methods that cause menu changes
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
#if true
// MySelf=1, PresentingViewController, NavigationController, TabBarController, SplitViewController, RootViewController
	func sideMenuController () -> ENSideMenuProtocol? {
		guard
			let viewController = self as? UIViewController
		else { return nil }

//		if let info = enSideMenuControllerInfo(viewController) {
//			return info.sideMenuController
//		} else {
//			return nil
//		}

		for option in enSideMenuOwners {
			let vc: UIViewController?
			switch option {
			case .MySelf:
				vc = viewController
//			case .PresentingViewController:
//				vc = viewController.presentingViewController
//			case .ParentViewController:
//				vc = viewController.parentViewController
			case .NavigationController:
				vc = viewController.navigationController
			case .SplitViewController:
				vc = viewController.splitViewController
			case .TabBarController:
				vc = viewController.tabBarController
//			case .RootViewController:
//				vc = UIApplication.sharedApplication().keyWindow?.rootViewController
			}
if let vc = vc {
	print("testing...\(Mirror(reflecting: vc).subjectType)")
}
			if let vc = vc as? ENSideMenuProtocol {
print("SUCCESS!!!")
				return vc
			}
		}
		return nil
	}
#else
    func sideMenuController () -> ENSideMenuProtocol? {
		print("-----------")
		guard
			let viewController = self as? UIViewController,
			var parentViewController = viewController.parentViewController
		else { print("NO PARENT VC: me=\(Mirror(reflecting: self).subjectType)"); return topMostController() }

		print("NO PARENT VC: me=\(Mirror(reflecting: self).subjectType)")
		repeat {
            if let parentViewController = parentViewController as? ENSideMenuProtocol {
				print("HAH - FOUND PARENT VC=\(Mirror(reflecting: parentViewController).subjectType)");
                return parentViewController
			}
			print("HAH - LOOK FOR ANOTHER PARENT");
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
			print("TopMostController - Loop on VC=\(Mirror(reflecting: presentedViewController).subjectType)");
            topController = presentedViewController
        }
		print("TopMostController - FOUND PRESENTED VC=\(Mirror(reflecting: topController).subjectType)");

        return topController as? ENSideMenuProtocol
    }
#endif
}

// MARK: - ENSideMenu

final class ENSideMenu : NSObject, UIGestureRecognizerDelegate {
    var menuWidth : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
            updateFrame()
        }
    }
	weak var sourceViewController : UIViewController? {
		willSet {
			sideMenuContainerView.removeFromSuperview()
			if let view = sourceViewController?.view {
				view.removeGestureRecognizer(menuPosition == .Left ? rightSwipeGestureRecognizer : leftSwipeGestureRecognizer)
			}
		}
		didSet {
			if let view = sourceViewController?.view {
print("add gr to \(view)")
				view.addSubview(sideMenuContainerView)
				view.addGestureRecognizer(menuPosition == .Left ? rightSwipeGestureRecognizer : leftSwipeGestureRecognizer)
				updateFrame()
			}
		}
	}
//	weak var sourceView : UIView? {
//		willSet {
//			sideMenuContainerView.removeFromSuperview()
//			if let view = sourceView {
//				view.removeGestureRecognizer(menuPosition == .Left ? rightSwipeGestureRecognizer : leftSwipeGestureRecognizer)
//			}
//		}
//		didSet {
//			if let view = sourceView {
//print("add gr to \(view)")
//				view.addSubview(sideMenuContainerView)
//				view.addGestureRecognizer(menuPosition == .Left ? rightSwipeGestureRecognizer : leftSwipeGestureRecognizer)
//				updateFrame()
//			}
//		}
//	}

	weak var sideMenuController : ENSideMenuProtocol?

	private var menuPosition:ENSideMenuPosition // = .Left
	private var blurStyle: UIBlurEffectStyle //  = .Light
	///  A Boolean value indicating whether the bouncing effect is enabled. The default value is TRUE.
    var bouncingEnabled = true
    /// The duration of the slide animation. Used only when `bouncingEnabled` is FALSE.
    var animationDuration: NSTimeInterval = 0.40
	/// The elasticity of the slide animation
	var elasticity: CGFloat = 0.20
	/// Magnitude of the "push"
	var magnitude: CGFloat = 5

    /// The delegate of the side menu
//    weak var delegate : ENSideMenuDelegate?
    /// A Boolean value indicating whether the left swipe is enabled.
    var allowLeftSwipe = true
    /// A Boolean value indicating whether the right swipe is enabled.
    var allowRightSwipe = true
    
    private(set) var menuViewController : UIViewController!
    private(set) var isMenuOpen = false

	private let sideMenuContainerView =  UIView()
    private var animator : UIDynamicAnimator
    private var needUpdateApperance = false
	private lazy var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = { UISwipeGestureRecognizer(target: self, action: "handleGesture:")}()
    private lazy var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = { UISwipeGestureRecognizer(target: self, action: "handleGesture:")}()

	// MARK: - Initializers

    /**
    Initializes an instance of a `ENSideMenu` object.
    
    :param: sourceView   The parent view of the side menu view.
    :param: menuPosition The position of the side menu view.
    
    :returns: An initialized `ENSideMenu` object, added to the specified view.
    */
    private init(sourceViewController: UIViewController, menuPosition: ENSideMenuPosition, blurStyle: UIBlurEffectStyle) { //  = .Left  = .Light
        self.menuPosition = menuPosition
        self.blurStyle = blurStyle
		self.sourceViewController = sourceViewController

        animator = UIDynamicAnimator(referenceView:sourceViewController.view)

		super.init()

        animator.delegate = self
		self.setupMenuView()

        // Add right swipe gesture recognizer
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.Right
        rightSwipeGestureRecognizer.delegate = self
        
        // Add left swipe gesture recognizer
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer.delegate = self
        
		sideMenuContainerView.addGestureRecognizer(menuPosition == .Left ? leftSwipeGestureRecognizer : rightSwipeGestureRecognizer)
		sideMenuContainerView.hidden = true

		// forces the addition of the gesture recognizer

		dispatch_async(dispatch_get_main_queue()) {
			self.sourceViewController = sourceViewController // willSet/didSet not called during init
		}
    }
    /**
    Initializes an instance of a `ENSideMenu` object.
    
    :param: sourceView         The parent view of the side menu view.
    :param: menuViewController A menu view controller object which will be placed in the side menu view.
    :param: menuPosition       The position of the side menu view.
    
    :returns: An initialized `ENSideMenu` object, added to the specified view, containing the specified menu view controller.
    */
    convenience init(sourceViewController: UIViewController, menuViewController menuVC: UIViewController, menuPosition: ENSideMenuPosition = .Left, blurStyle: UIBlurEffectStyle = .Light) {
        self.init(sourceViewController: sourceViewController, menuPosition: menuPosition, blurStyle: blurStyle)

        menuViewController = menuVC
		if let menuViewController = menuViewController as? ENSideMenuReference {
			menuViewController.sideMenu = self
		}
        menuViewController.view.frame = sideMenuContainerView.bounds
        menuViewController.view.autoresizingMask =  [.FlexibleHeight, .FlexibleWidth]
        sideMenuContainerView.addSubview(self.menuViewController.view)
    }

	// MARK: - Methods

    /**
    Updates the frame of the side menu view.
    */
    private func updateFrame() {
		guard let sourceView = sourceViewController?.view else { return }

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
		//guard let sourceView = sourceView else { return }

        updateFrame() // Configure side menu container

        sideMenuContainerView.backgroundColor = UIColor.clearColor()
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false
        sideMenuContainerView.layer.shadowOffset = (menuPosition == .Left) ? CGSizeMake(1.0, 1.0) : CGSizeMake(-1.0, -1.0)
        sideMenuContainerView.layer.shadowRadius = 1.0
        sideMenuContainerView.layer.shadowOpacity = 0.125
        sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
        
        //sourceView.addSubview(sideMenuContainerView) // done in setter for sourceView
        
		// Add blur view
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle)) as UIVisualEffectView
		visualEffectView.frame = sideMenuContainerView.bounds
		visualEffectView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		sideMenuContainerView.addSubview(visualEffectView)
    }
    
    private func toggleMenuShouldOpen (shouldOpen: Bool, forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
        if shouldOpen && sideMenuController?.sideMenuShouldOpenSideMenu() == false {
            return
        }

		guard let sourceView = sourceViewController?.view else { return }

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
						self.sideMenuController?.sideMenuDidOpen()
					} else {
						self.sideMenuContainerView.hidden = true
						self.sideMenuController?.sideMenuDidClose()
					}
            })
        }

		if shouldOpen {
			sideMenuController?.sideMenuWillOpen()
		} else {
			sideMenuController?.sideMenuWillClose()
		}
    }

	// MAKR: - Gesture Recognizer 

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let
			swipeGestureRecognizer = gestureRecognizer as? UISwipeGestureRecognizer,
			viewController = sourceViewController as? ENSideMenuProtocol where viewController.sideMenuShouldOpenSideMenu()
			//info = enSideMenuControllerInfo(viewController) where info.showSideMenu
		else { print("FUCKED!"); return false }

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
    func sideMenuController(animator: UIDynamicAnimator) {
		if self.isMenuOpen {
			self.sideMenuController?.sideMenuDidOpen()
		}
		else {
			self.sideMenuContainerView.hidden = true
			self.sideMenuController?.sideMenuDidClose()
		}
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
#if DEBUG
        print("resume")
#endif
    }
}



/*
typealias SideMenuInfo = (sideMenuController: ENSideMenuProtocol, showSideMenu: Bool)

#if true
func enSideMenuControllerInfo(viewController: UIViewController) -> SideMenuInfo? {
	print("enSideMenuControllerInfo: viewController==\(Mirror(reflecting: viewController).subjectType)")

	for option in enSideMenuOwners {
		let visibleConformsToSideMenuControl = viewController is ENSideMenuControl
		var sideMenuController: UIViewController?
		var showSideMenu: Bool = false

print("-OPTION: \(option)")
		switch option {
		case .MySelf:
			sideMenuController = viewController
			showSideMenu = visibleConformsToSideMenuControl
//		case .PresentingViewController:
//			sideMenuController = viewController.presentingViewController
//			showSideMenu = visibleConformsToSideMenuControl
//		case .ParentViewController:
//			sideMenuController = viewController.parentViewController
//			showSideMenu = visibleConformsToSideMenuControl
		case .NavigationController:
			if let navController = viewController.navigationController {
				sideMenuController = navController
				showSideMenu = viewController === navController.visibleViewController
			}
		case .SplitViewController:
			if let splitViewController = viewController.splitViewController {
				sideMenuController = splitViewController
				if splitViewController.viewControllers.count == 2 {
					let detailViewController = splitViewController.viewControllers[1]
					showSideMenu = detailViewController === viewController
				}
			}
		case .TabBarController:
			if let tabBarController = viewController.tabBarController {
				sideMenuController = tabBarController
				showSideMenu = viewController === tabBarController.selectedViewController
			}
//		case .RootViewController:
//			if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
//				showSideMenu = rootViewController === viewController
//			}
		}

if let vc = sideMenuController {
	print("testing...\(Mirror(reflecting: vc).subjectType)")
}
if let vc = sideMenuController?.presentedViewController {
	print("Yikes! presented == \(Mirror(reflecting: vc).subjectType)")
}
		// Has to implement the protocol, AND not be presenting some other controller
		if let
			sideMenuController = sideMenuController,
			vc = sideMenuController as? ENSideMenuProtocol
		{
print("SUCCESS!!!")
			return (vc, showSideMenu && visibleConformsToSideMenuControl)
		}
	}
	return nil
}

#else

// Note: this gets called by the "controller - the thing that put in the gesture recognizer OR handles the action method of some button...
func enSideMenuControllerInfo(viewController: UIViewController) -> SideMenuInfo? {
	print("enSideMenuControllerInfo: viewController==\(Mirror(reflecting: viewController).subjectType)")

	for option in enSideMenuOwners {
		var sideMenuController: UIViewController?
		var showSideMenu: Bool = false

print("-OPTION: \(option)")
		switch option {
		case .MySelf:
			sideMenuController = viewController
			showSideMenu = visibleConformsToSideMenuControl
		case .PresentingViewController:
			sideMenuController = viewController.presentingViewController
			showSideMenu = visibleConformsToSideMenuControl
		case .ParentViewController:
			sideMenuController = viewController.parentViewController
			showSideMenu = visibleConformsToSideMenuControl
		case .NavigationController:
			if let navController = viewController as? UINavigationController {
				sideMenuController = navController
				showSideMenu = viewController === navController.visibleViewController
			}
		case .SplitViewController:
			if let splitViewController = viewController.splitViewController {
				sideMenuController = splitViewController
				if splitViewController.viewControllers.count == 2 {
					let detailViewController = splitViewController.viewControllers[1]
					showSideMenu = detailViewController === viewController
				}
			}
		case .TabBarController:
			if let tabBarController = viewController.tabBarController {
				sideMenuController = tabBarController
				showSideMenu = viewController === tabBarController.selectedViewController
			}
		case .RootViewController:
			if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
				showSideMenu = rootViewController === viewController
			}
		}

// 		let visibleConformsToSideMenuControl = viewController is ENSideMenuControl

if let vc = sideMenuController {
	print("testing...\(Mirror(reflecting: vc).subjectType)")
}
if let vc = sideMenuController?.presentedViewController {
	print("Yikes! presented == \(Mirror(reflecting: vc).subjectType)")
}
		// Has to implement the protocol, AND not be presenting some other controller
		if let
			sideMenuController = sideMenuController,
			vc = sideMenuController as? ENSideMenuProtocol
		{
print("SUCCESS!!!")
			return (vc, showSideMenu && visibleConformsToSideMenuControl)
		}
	}
	return nil
}

#endif
*/
