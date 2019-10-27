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

import UIKit


/// Protocol that defines a type that can handle an incoming URL.
public protocol URLHandler: class {
    func handle(_ url: URL, pathVariables: [String: String], options: [UIApplication.OpenURLOptionsKey: Any]?) -> Bool
}

private typealias URLPatternHandlerPair = (pattern: String, handler: URLHandler)


/// Routes incoming URLs to `URLHandler`. Usually an instance of this is created in and owned by the `AppDelegate`.
public class URLRouter {
    
    // MARK: Private
    
    private let patternWrapCharacter = "!"
    private var urlPatternHandlerPairs = [URLPatternHandlerPair]()
    
    // MARK: Lifecycle
    
    /// Creates a new instance of `URLRouter`.
    public init() {
    }
    
    // MARK: Routing
    
    /// Routes an incoming `URL` to matching `URLHandler`. The handlers will be checked in the order they were added.
    /// - Parameter url: The `URL` to route.
    /// - Parameter options: Options passed from the `AppDelegate`.
    /// - Returns: `Bool` indicating the URL was routed.
    @discardableResult
    public func route(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]? = nil) -> Bool {
        for urlPatternHandlerPair in self.urlPatternHandlerPairs {
            let urlPatternString = urlPatternHandlerPair.pattern
            let urlHandler = urlPatternHandlerPair.handler
            
            guard let urlPattern = URL(string: urlPatternString) else {
                continue
            }
            
            let urlPatternPathComponents = urlPattern.path.components(separatedBy: "/")
            let urlPathComponents = url.path.components(separatedBy: "/")
            let nonNilUrlPatternHost = urlPattern.host ?? ""
            let hostMatches = nonNilUrlPatternHost == url.host || "www." + nonNilUrlPatternHost == url.host
            
            // Make sure the host and the number of path components match
            guard urlPattern.scheme == url.scheme, hostMatches, urlPatternPathComponents.count == urlPathComponents.count else {
                continue
            }
            
            // Look at the urlPatternPathComponents to extract any path indexes that may contain variables
            // For those that don't, ensure the given path component at that index matches the pattern
            var pathComponentVariableIndexes = [Int]()
            var isPathPatternIdentical = true
            for (index, urlPatternPathComponent) in urlPatternPathComponents.enumerated() {
                if urlPatternPathComponent.prefix(1) == self.patternWrapCharacter && urlPatternPathComponent.suffix(1) == self.patternWrapCharacter {
                    pathComponentVariableIndexes.append(index)
                } else if urlPathComponents[index] != urlPatternPathComponent {
                    isPathPatternIdentical = false
                }
            }
            
            guard isPathPatternIdentical else {
                continue
            }
            
            // Extract the variables from the given url path components
            var pathVariables = [String: String]()
            pathComponentVariableIndexes.forEach {
                pathVariables[urlPatternPathComponents[$0].replacingOccurrences(of: self.patternWrapCharacter, with: "")] = urlPathComponents[$0]
            }
            
            if urlHandler.handle(url, pathVariables: pathVariables, options: options) == true {
                return true
            }
        }
        
        return false
    }
    
    /// Adds a `URLHandler` to the receiver.
    /// - Parameter urlHandler: The `URLHandler` to add.
    /// - Parameter urlPattern: The URL pattern to check to determine if the given `URLHandler` can handle the URL.
    public func add(urlHandler: URLHandler, for urlPattern: String) {
        self.urlPatternHandlerPairs.append(URLPatternHandlerPair(pattern: urlPattern, handler: urlHandler))
    }
    
    /// Removes `URLHandler` from the receiver for the given pattern.
    /// - Parameter urlPattern: The URL pattern associated with the `URLHandler` that needs to be removed.
    public func removeUrlHandler(for urlPattern: String) {
        if let index = self.urlPatternHandlerPairs.firstIndex(where: { $0.pattern == urlPattern }) {
            self.urlPatternHandlerPairs.remove(at: index)
        }
    }
}
