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

import MapKit


/// A protocol that UI componants can conform to that are reusable (ie. `UITableViewCell`).
///
/// By default, all UIView confirm to this type via default extension where `resuseIdentifier` is
/// the same name as the class type. Because of this, you should use the class name as the reuse
/// identifier in your Interface Builder files.
public protocol ReuseIdentifiable {
    
    /// The unique reuse identifier for the receiver.
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable where Self: UIView {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension ReuseIdentifiable where Self: MKAnnotationView {
    
    /// Convenience method for dequeuing a `MKAnnotation` without having to define the reuse
    /// identifier.
    ///
    /// - Note: You must have a concrete subclass on `MKAnnotationView` to use this method.
    ///
    /// - Warning: This will throw an `fatalError` if there is a mismatch between the dequeued view
    /// and the type of the receiver.
    ///
    /// - Parameters:
    ///     - mapView: The `MKMapView` to dequeue the annotation view from.
    ///     - annotation: The `MKAnnotation` to that will be placed in the returned `MKAnnotationView`.
    /// - Returns: Instance of the annotation view dequeued from the map view.
    public static func dequeue(from mapView: MKMapView, with annotation: MKAnnotation) -> Self {
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: self.reuseIdentifier, for: annotation) as? Self else {
            fatalError("Could not dequeue annoation view \(self.reuseIdentifier) from \(mapView)")
        }
        return annotationView
    }
}

extension ReuseIdentifiable where Self: UITableViewCell {
   
    /// Convenience method for dequeuing a `UITableViewCell` for an unknown index path without
    /// having to define the reuse identifier.
    ///
    /// - Note: You must have a concrete subclass on `UITableViewCell` to use this method.
    ///
    /// - Warning: This will throw an `fatalError` if there is a mismatch between the dequeued table
    /// cell and the type of the receiver.
    ///
    /// - Parameters:
    ///     - tableView: The `UITableView` to dequeue the table cell from.
    ///
    /// - Returns: Instance of the table cell dequeued from the table view.
    public static func dequeue(from tableView: UITableView) -> Self {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier) as? Self else {
            fatalError("Could not dequeue cell \(self.reuseIdentifier) from \(tableView)")
        }
        return cell
    }
    
    /// Convenience method for dequeuing a `UITableViewCell`  without having to define the reuse
    /// identifier.
    ///
    /// - Note: You must have a concrete subclass on `UITableViewCell` to use this method.
    ///
    /// - Warning: This will throw an `fatalError` if there is a mismatch between the dequeued table
    /// cell and the type of the receiver.
    ///
    /// - Parameters:
    ///     - tableView: The `UITableView` to dequeue the table cell from.
    ///     - indexPath: The `IndexPath` the cell will be placed at.
    ///
    /// - Returns: Instance of the table cell dequeued from the table view.
    public static func dequeue(from tableView: UITableView, for indexPath: IndexPath) -> Self {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as? Self else {
            fatalError("Could not dequeue cell \(self.reuseIdentifier) from \(tableView)")
        }
        return cell
    }
}

extension UICollectionReusableView: ReuseIdentifiable {
}

extension UITableViewHeaderFooterView: ReuseIdentifiable {
}

extension UITableViewCell: ReuseIdentifiable {
}
