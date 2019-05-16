//
//  Copyright © 2019 Theis Holdings, LLC. All rights reserved.
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
