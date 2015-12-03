//
//  SideMenu.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 24.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//  Copyright (c) 2015 David Hoerl. All rights reserved.
//

import UIKit


enum ENSideMenuOwners: Int {
	//case MySelf=1, PresentingViewController, ParentViewController, NavigationController, SplitViewController, TabBarController, RootViewController
	case NavigationController=1, SplitViewController, TabBarController, PagingController, ChildController, RootViewController
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
	func sideMenuShouldOpenSideMenu() -> Bool
}
extension ENSideMenuDelegate {
	func sideMenuWillOpen() { }
	func sideMenuWillClose() { }
	func sideMenuDidOpen() { }
	func sideMenuDidClose() { }

	func sideMenuShouldOpenSideMenu() -> Bool { print("ASKED IF SHOULD"); return true }	// defaults to "works all the time"
}

// The entity that knows how to change the current view controller
// * typically a container view: Navigation Controller, TabBar Controller, etc
protocol ENSideMenuProtocol : class, ENSideMenuDelegate {
	var sideMenu : ENSideMenu? { get set }	// set so we the one sideMenu instance can be moved from one controller to another
	func setContentViewController(contentViewController: UIViewController)

	func visibleViewController() -> ENSideMenuDelegate?	// UIPageViewController or childViewControllers need to override this
}
extension ENSideMenuProtocol {
	func visibleViewController() -> ENSideMenuDelegate? {
		func drillDown(startViewController: UIViewController) -> UIViewController {
			var viewController = startViewController

			switch startViewController {
			case let vc as UINavigationController:
				if vc.viewControllers.count == 1, let vc1 = vc.visibleViewController {
					viewController = vc1
				}
			case let vc as UISplitViewController:
				if vc.viewControllers.count == 2 {
					viewController = vc.viewControllers[1]	// detail controller
				}
			case let vc as UITabBarController:
				if let vc1 = vc.selectedViewController {
					viewController = vc1
				}
			default:
				break
			}
			return viewController
		}

		if var returnViewController = self as? UIViewController {
			var oldVC: UIViewController
			repeat {
				oldVC = returnViewController
				if !(oldVC is ENSideMenuProtocol), let vc = oldVC as? ENSideMenuDelegate  {
					return oldVC.presentedViewController == nil ? vc : nil
				}
				returnViewController = drillDown(returnViewController)
			} while oldVC !== returnViewController
		}
		return nil
	}

	func sideMenuShouldOpenSideMenu() -> Bool {
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
	func toggleSideMenuView()
	func hideSideMenuView (forceNoBounce: Bool, duration: NSTimeInterval)
	func showSideMenuView (forceNoBounce: Bool, duration: NSTimeInterval)
	func isSideMenuOpen() -> Bool
	func fixSideMenuSize()
	func sideMenuController() -> ENSideMenuProtocol?

	func pageViewController() -> UIViewController? // Override if you use a UIPageViewController so presented view can return it
}
extension ENSideMenuControl {
	/**
	Changes current state of side menu view.
	*/
	func toggleSideMenuView() {
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
	func isSideMenuOpen() -> Bool {
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
	Returns a view controller containing a side menu controller

	:returns: A `UIViewController`responding to `ENSideMenuProtocol` protocol
	*/

	func sideMenuController() -> ENSideMenuProtocol? {
		guard
			let viewController = self as? UIViewController
		else { return nil }

		for option in enSideMenuOwners {
			let vc: UIViewController?
			switch option {
			case .NavigationController:
				vc = viewController.navigationController
			case .SplitViewController:
				vc = viewController.splitViewController
			case .TabBarController:
				vc = viewController.tabBarController
			case .PagingController:
				vc = pageViewController()
			case .ChildController:
				vc = viewController.parentViewController
			case .RootViewController:
				vc = UIApplication.sharedApplication().keyWindow?.rootViewController
			}
//if let vc = vc { print("testing...\(Mirror(reflecting: vc).subjectType)") }
			if let vc = vc as? ENSideMenuProtocol {
				return vc
			}
		}
		return nil
	}

	func pageViewController() -> UIViewController? { return nil }
}

// MARK: - ENSideMenu

final class ENSideMenu : NSObject, UIGestureRecognizerDelegate {
	var menuWidth : CGFloat = 160.0 {
		didSet {
			needUpdateApperance = true
			updateSideMenuApperanceIfNeeded()
			updateFrame()
		}
	}
	weak var sourceViewController : UIViewController? {
		willSet {
			containerView.removeFromSuperview()
			if let view = sourceViewController?.view {
				view.removeGestureRecognizer(menuPosition == .Left ? rightSwipeGestureRecognizer : leftSwipeGestureRecognizer)
				view.removeGestureRecognizer(panGestureRecognizer)
			}
			animator = nil
		}
		didSet {
			if let view = sourceViewController?.view {
				view.addSubview(containerView)
				view.addGestureRecognizer(menuPosition == .Left ? rightSwipeGestureRecognizer : leftSwipeGestureRecognizer)
				view.addGestureRecognizer(panGestureRecognizer)

				updateFrame()

				animator = UIDynamicAnimator(referenceView: view)
				animator.delegate = self
			}
		}
	}

	private var menuPosition:ENSideMenuPosition // = .Left
	private var blurStyle: UIBlurEffectStyle //  = .Light
	//  A Boolean value indicating whether the bouncing effect is enabled. The default value is TRUE.
	var bouncingEnabled = true
	// The duration of the slide animation. Used only when `bouncingEnabled` is FALSE.
	var animationDuration: NSTimeInterval = 0.40
	// The elasticity of the slide animation
	var elasticity: CGFloat = 0.20
	// Magnitude of the "push"
	var magnitude: CGFloat = 5

	// A Boolean value indicating whether the left swipe is enabled.
	var allowLeftSwipe = true
	// A Boolean value indicating whether the right swipe is enabled.
	var allowRightSwipe = true
	// A Boolean value indicating whether the right swipe is enabled.
	var allowTapToDismiss = true
	// A Boolean value indicating whether the pan gesture is enabled.
	var allowPanGesture = true
	private(set) var menuViewController : UIViewController!
	private(set) var isMenuOpen = false

	private let containerView = ENView()
	private let tapToHideView = UIView()
	private var animator : UIDynamicAnimator!
	private var needUpdateApperance = false
	private lazy var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = { UISwipeGestureRecognizer(target: self, action: "handleGesture:")}()
	private lazy var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = { UISwipeGestureRecognizer(target: self, action: "handleGesture:")}()
	private lazy var tapGestureRecognizer: UITapGestureRecognizer = { UITapGestureRecognizer(target: self, action: "handleGesture:")}()
	private lazy var panGestureRecognizer: UIPanGestureRecognizer = { UIPanGestureRecognizer(target: self, action: "handlePan:")}()

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

		panGestureRecognizer.delegate = self

		containerView.addGestureRecognizer(menuPosition == .Left ? leftSwipeGestureRecognizer : rightSwipeGestureRecognizer)
		containerView.hidden = true

		// forces the addition of the gesture recognizer

		dispatch_async(dispatch_get_main_queue()) {
			self.sourceViewController = sourceViewController // willSet/didSet not called during init
		}
	}
	/**
	Initializes an instance of a `ENSideMenu` object.
	
	:param: sourceView		 The parent view of the side menu view.
	:param: menuViewController A menu view controller object which will be placed in the side menu view.
	:param: menuPosition	   The position of the side menu view.
	
	:returns: An initialized `ENSideMenu` object, added to the specified view, containing the specified menu view controller.
	*/
	convenience init(sourceViewController: UIViewController, menuViewController menuVC: UIViewController, menuPosition: ENSideMenuPosition = .Left, blurStyle: UIBlurEffectStyle = .Light) {
		self.init(sourceViewController: sourceViewController, menuPosition: menuPosition, blurStyle: blurStyle)

		menuViewController = menuVC
		if let menuViewController = menuViewController as? ENSideMenuReference {
			menuViewController.sideMenu = self
		}
		menuViewController.view.frame = containerView.bounds
		menuViewController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		containerView.addSubview(self.menuViewController.view)

		tapToHideView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		tapToHideView.backgroundColor = UIColor.clearColor()
		tapToHideView.addGestureRecognizer(tapGestureRecognizer)
	}

	// MARK: - Methods

	// Updates the frame of the side menu view.
	private func updateFrame() {
		guard let sourceView = sourceViewController?.view else { return }

		let size = sourceView.frame.size
		let menuFrame = CGRectMake(
			(menuPosition == .Left) ?
				(isMenuOpen ? 0 : -menuWidth-1.0) :
				(isMenuOpen ? size.width-menuWidth : size.width+1.0),
			sourceView.frame.origin.y,
			menuWidth,
			size.height
		)
		containerView.frame = menuFrame

		var frame = sourceView.bounds
		frame.origin.x = menuPosition == .Left ? 0 : menuWidth-size.width
		tapToHideView.frame = frame
	}

	private func setupMenuView() {
		//guard let sourceView = sourceView else { return }

		updateFrame() // Configure side menu container

		containerView.backgroundColor = UIColor.clearColor()
		containerView.clipsToBounds = false
		containerView.layer.masksToBounds = false
		containerView.layer.shadowOffset = (menuPosition == .Left) ? CGSizeMake(1.0, 1.0) : CGSizeMake(-1.0, -1.0)
		containerView.layer.shadowRadius = 1.0
		containerView.layer.shadowOpacity = 0.125
		containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).CGPath
		
		//sourceView.addSubview(sideMenuContainerView) // done in setter for sourceView
		
		// Add blur view
		let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle)) as UIVisualEffectView
		visualEffectView.frame = containerView.bounds
		visualEffectView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		containerView.addSubview(visualEffectView)
	}
	
	private func toggleMenuShouldOpen (shouldOpen: Bool, forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
		guard let sideMenuController = sourceViewController as? ENSideMenuProtocol else { fatalError("Wrong controller") }

		if shouldOpen && sideMenuController.sideMenuShouldOpenSideMenu() == false {
			return
		}

		guard let sourceView = sourceViewController?.view else { return }

		updateSideMenuApperanceIfNeeded()

		if shouldOpen {
			containerView.hidden = false
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
			
			let gravityBehavior = UIGravityBehavior(items: [containerView])
			gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX,  0)
			gravityBehavior.magnitude = magnitude
			animator.addBehavior(gravityBehavior)
			
			let collisionBehavior = UICollisionBehavior(items: [containerView])
			collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryPointX, boundaryPointY),
				toPoint: CGPointMake(boundaryPointX, size.height))
			animator.addBehavior(collisionBehavior)
			
			let pushBehavior = UIPushBehavior(items: [containerView], mode: UIPushBehaviorMode.Instantaneous)
			pushBehavior.magnitude = pushMagnitude
			animator.addBehavior(pushBehavior)
			
			let menuViewBehavior = UIDynamicItemBehavior(items: [containerView])
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
				animations: {() -> Void in
					self.containerView.frame = destFrame
				},
				completion: { (Bool) -> Void in
					if self.isMenuOpen {
						sideMenuController.sideMenuDidOpen()
					} else {
						self.containerView.hidden = true
						sideMenuController.sideMenuDidClose()
					}
			})
		}

		if shouldOpen {
			if allowTapToDismiss {
				containerView.insertSubview(tapToHideView, belowSubview: menuViewController.view)
			}
			sideMenuController.sideMenuWillOpen()
		} else {
			tapToHideView.removeFromSuperview()
			sideMenuController.sideMenuWillClose()
		}
	}

	// MARK: - Gesture Recognizer

	func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let
			viewController = sourceViewController,
			view = viewController.view,
			sideMenuProtocol = viewController as? ENSideMenuProtocol where sideMenuProtocol.sideMenuShouldOpenSideMenu()
		else { return false }

		if let swipeGestureRecognizer = gestureRecognizer as? UISwipeGestureRecognizer {
			if !allowLeftSwipe && swipeGestureRecognizer.direction == .Left {
				return false
			}
			if !allowRightSwipe && swipeGestureRecognizer.direction == .Right {
				return false
			}
			if isMenuOpen == false {
				containerView.hidden = false
			}
			return true
		}
		else if let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
			if allowPanGesture == false {
				return false
			}
			animator.removeAllBehaviors()

			let touchPosition = panRecognizer.locationOfTouch(0, inView: view)
			if menuPosition == .Left {
				if isMenuOpen {
					if touchPosition.x < menuWidth {
						return true
					}
				}
				else {
					if touchPosition.x < 50 {
						return true
					}
				}
			}
			else {
				if isMenuOpen {
					if touchPosition.x > CGRectGetWidth(view.frame) - menuWidth {
						return true
					}
				}
				else {
					if touchPosition.x > CGRectGetWidth(view.frame)-25 {
						return true
					}
				}
			}
			return false
		}
		return true
	}

	func handleGesture(gesture: UIGestureRecognizer) {
		if let swipeGestureRecognizer = gesture as? UISwipeGestureRecognizer {
			toggleMenuShouldOpen((self.menuPosition == .Right && swipeGestureRecognizer.direction == .Left) || (self.menuPosition == .Left && swipeGestureRecognizer.direction == .Right))
		}
		else if gesture is UITapGestureRecognizer {
			hideSideMenu()
		}
	}

	func handlePan(recognizer : UIPanGestureRecognizer) {
		guard let view = sourceViewController?.view else { return }

		let leftToRight = recognizer.velocityInView(recognizer.view).x > 0
		
		switch recognizer.state {
		case .Began:
			containerView.hidden = false
			break

		case .Changed:
			//containerView.hidden = false

			let translation = recognizer.translationInView(view).x
			let xPoint : CGFloat = containerView.center.x + translation + (menuPosition == .Left ? 1 : -1) * menuWidth / 2
			
			if menuPosition == .Left {
				if xPoint <= 0 || xPoint > CGRectGetWidth(containerView.frame) {
					return
				}
			}
			else {
				if xPoint <= view.frame.size.width - menuWidth || xPoint >= view.frame.size.width
				{
					return
				}
			}

			containerView.center.x += translation
			recognizer.setTranslation(CGPointZero, inView: view)
			
		default:
			let shouldClose = menuPosition == .Left ?
				!leftToRight && CGRectGetMaxX(containerView.frame) < menuWidth :
				 leftToRight && CGRectGetMinX(containerView.frame) >  (view.frame.size.width - menuWidth)
			toggleMenuShouldOpen(!shouldClose)
		}
	}

	// MARK: - Other Private

	private func updateSideMenuApperanceIfNeeded() {
		guard needUpdateApperance == true else { return }

		var frame = containerView.frame
		frame.size.width = menuWidth
		containerView.frame = frame
		containerView.layer.shadowPath = UIBezierPath(rect: containerView.bounds).CGPath

		needUpdateApperance = false
	}

	// MARK: - Public

	// Toggles the state of the side menu.
	func toggleMenu() {
		if isMenuOpen {
			toggleMenuShouldOpen(false)
		}
		else {
			updateSideMenuApperanceIfNeeded()
			toggleMenuShouldOpen(true)
		}
	}
	// Shows the side menu if the menu is hidden.
	func showSideMenu (forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
		if !isMenuOpen {
			toggleMenuShouldOpen(true, forceNoBounce: forceNoBounce, duration: duration)
		}
	}
	// Hides the side menu if the menu is showed.
	func hideSideMenu (forceNoBounce: Bool = false, duration: NSTimeInterval = 0) {
		if isMenuOpen {
			toggleMenuShouldOpen(false, forceNoBounce: forceNoBounce, duration: duration)
		}
	}
}
extension ENSideMenu: UIDynamicAnimatorDelegate {
	func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
		guard let sideMenuController = sourceViewController as? ENSideMenuProtocol else { fatalError("Wrong controller") }

		if self.isMenuOpen {
			if allowTapToDismiss {
				containerView.insertSubview(tapToHideView, belowSubview: menuViewController.view)
				//containerView.addSubview(tapToHideView)
			}
//print("Tap \(tapToHideView.frame)")
//print("containerView \(containerView.frame)")
//print("menuViewController.view \(menuViewController.view.frame)")
			sideMenuController.sideMenuDidOpen()
		}
		else {
			// Pan gesture removes all the animation objects, triggering this callback
			switch panGestureRecognizer.state {
			case .Began, .Changed:
				break
			default:
				containerView.hidden = true
			}
			tapToHideView.removeFromSuperview()
			sideMenuController.sideMenuDidClose()
		}
	}
	
	func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
#if DEBUG
		print("resume")
#endif
	}
}

// So that we can hitTest the clear view that handles "Tap to Dismiss"
private final class ENView : UIView {
	// https://developer.apple.com/library/ios/qa/qa2013/qa1812.html
	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		for view in subviews.reverse() where view.userInteractionEnabled {
			let subPoint = view.convertPoint(point, fromView: self)
			if CGRectContainsPoint(view.bounds, subPoint) {
				return view.hitTest(subPoint, withEvent: event)
			}
		}
		return super.hitTest(point, withEvent: event)
	}
}
