ENSwiftSideMenu
===============

A simple side menu for iOS 9 written in Swift. Using the UIDynamic framework, UIGestures and UIBlurEffect.

---  

## dhoerl Changes

This project has been significantly changed. While I did so to meet my special needs (Tab Bar Support, tabs can opt in and out of showing the menu), 
I must say: "This is a brilliant piece of work!" It would have taken me a long long time to produce what *Evgeny Nazarov* created, and I for sure
I owe him a huge thanks!

### My changes:    

Dec 4, 2015    

  
* all UIKit class extensions were converted to use Swift protocols most with defaults methods in protocol extensions
* fully support tab Controllers (optionally hide the tab bar, my requirement)
* tabs can opt in or out of controlling the slide in menu, and can be most any container view
* designed to support most container classes, even custom ones (this mostly untested)
* only permit the first view of a naviation controller as a menu controller
* allow a tab view controller with optional navigation controllers to use the side menu instead of the tab bar
* choose to animate via the dynamic animator, or a frame change (latter needed when changing tabs)
* spaces to tabs
* significatly edited to my style (which should be close to the Apple recommended style)
* requires iOS 9

***

##Demo
![](https://raw.githubusercontent.com/evnaz/ENSwiftSideMenu/master/side_menu.gif)

##Requirements for this Fork
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
        
        sideMenu = ENSideMenu(sourceView: self, menuViewController: MyMenuViewController(), menuPosition:.Left)
        
        // show the navigation bar over the side menu view
        sideMenu.containerViewIsSecond = true // default value, under the nav or tab bar
    }
```

Check two example project for more details: one uses a navigation controller whose rootViewController gets changed, the other a tab bar controller.

##License

The MIT License (MIT)

Copyright (c) 2014-2015 Evgeny Nazarov    
Copyright (c) 2015 David Hoerl

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
