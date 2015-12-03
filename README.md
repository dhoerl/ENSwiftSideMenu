ENSwiftSideMenu
===============

A simple side menu for iOS 9 written in Swift. Using the UIDynamic framework, UIGestures and UIBlurEffect.

## DHOERL Changes

This project has been significanly changed. All UIKit class extensions were converted to use Swift protocols, with defaults methods 
provided via extensions. Other changes:    
* only permit the first view of a naviation controller as a menu controller
* allow a tab view controller with optional navigation controllers to use the side menu instead of the tab bar
* spaces to tabs
* significatly edited to my style
* now requires iOS 9
- 
##Demo
![](https://raw.githubusercontent.com/evnaz/ENSwiftSideMenu/master/side_menu.gif)

##Requirements
* Xcode 7.1
* iOS 9 or higher

##How to use
1. Import `ENSideMenu.swift` and `ENSideMenuNavigationController.swift` to your project folder
2. Create a root UINavigationController subclassing from ENSideMenuNavigationController
3. Create a UIViewController for side menu
4. Initilize the menu view with a source view and menu view controller:
```swift
  override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MyMenuViewController(), menuPosition:.Left)
        
        // show the navigation bar over the side menu view
        view.bringSubviewToFront(navigationBar)
    }
```

Check example project for more explanation

##License

The MIT License (MIT)

Copyright (c) 2014 Evgeny Nazarov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
