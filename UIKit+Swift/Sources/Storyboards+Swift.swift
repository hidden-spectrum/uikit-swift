//
//  Copyright (c) 2019 Theis Holdings, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/**
 A lightweight type that stores the name of an available storyboard in the project.
 
 - You should extend this struct to include references to all your available storyboards:
 
 ```
 extension StoryboardReference {
    static let login = StoryboardReference("Login")
    static let main = StoryboardReference("Main")
 }
 ```
 */
public struct StoryboardReference {
    public let name: String
    
    public init(_ name: String) {
        self.name = name
    }
}


/**
 A protocol that UIKit types can conform to if they can be referenced in a Storyboard by a name. By
 default, UIViewController has been conformed to this protocol via a default extension that uses
 the class name as the `storyboardIdentifier`. Therefore, your UIViewControllers should have the
 same name as the class in your storyboards.
 */
public protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

public extension StoryboardIdentifiable where Self: UIViewController {
    public static var storyboardIdentifier: String {
        return String(describing: self)
    }
}


public extension UIStoryboard {
    /**
     A convenience initializer that allows you to instantiate a storyboard from a
     `StoryboardReference`.
     
     - Parameter reference: Name of the storyboard as it exists in your project (excluding file the
     file extension).
     
     - Example:
     ```
     let storyboard = UIStoryboard(.main)
     ```
     
     See `StoryboardReference` for more info.
    */
    public convenience init(_ reference: StoryboardReference) {
        self.init(name: reference.name, bundle: nil)
    }
    
    public func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        
        return viewController
    }
}


extension UIViewController: StoryboardIdentifiable {
}
