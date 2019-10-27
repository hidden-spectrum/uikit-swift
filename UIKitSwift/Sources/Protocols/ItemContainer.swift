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

import Foundation


/// A basic protocol that defines something that contains arbitrary items.
public protocol ItemContainer {
    associatedtype Item: Equatable
    var items: [Item] { get }
}


/// Contains an arbitrary array of Equatable items.
public struct Section<T: Equatable>: ItemContainer {
    public let items: [T]
    
    public init(items: [T]) {
        self.items = items
    }
}


public extension Array where Element: ItemContainer {
    
    /// Looks up the index of the `ItemContainer` in an array that contains the given item.
    ///
    /// - Parameter item: The item to search for.
    /// - Returns: The first index of the `ItemContainer` containing the item, or nil.
    func indexContaining(item: Element.Item) -> Int? {
        return self.firstIndex(where: { element -> Bool in
            return element.items.contains(item)
        })
    }
}
