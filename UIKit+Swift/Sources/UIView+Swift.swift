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

// MARK: Interface Builder Inspectable Properties

public extension UIView {
    
    /// Inspectable variable that exposes the view's layer border color to Interface Builder.
    @IBInspectable public var borderColor: UIColor? {
        get {
            if let borderColor = self.layer.borderColor {
                return UIColor(cgColor: borderColor)
            } else {
                return nil
            }
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    /// Inspectable variable that exposes the view's layer border width to Interface Builder.
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    /// Inspectable variable that exposes the view's layer corner radius to Interface Builder.
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
        }
    }
}

// MARK: Edge-Specific Borders

public extension UIView {
    
    /**
     Adds a border from the receiver on the given edge.
 
     - Parameters:
        - edge: The edge to add a border to.
        - color: The color of the border.
        - thickness: The thickness of the border (defaults to hairline for the given
        device scale.
     */
    public func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat = 1 / UIScreen.main.scale) {
        if edge == .all {
            self.borderColor = color
            self.borderWidth = thickness
            return
        }
        
        self.removeBorder(edge: edge)
        let borderView = UIView()
        borderView.autoresizesSubviews = true
        
        switch edge {
        case .top:
            borderView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            borderView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        case .bottom:
            borderView.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            borderView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        case .left:
            borderView.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            borderView.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        case .right:
            borderView.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            borderView.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        default:
            break
        }
        
        borderView.tag = edge.viewTag
        borderView.layer.zPosition = .greatestFiniteMagnitude
        borderView.backgroundColor = color
        self.addSubview(borderView)
    }
    
    /**
     Removes a border from the receiver on the given edge.
     
     - Parameters:
        - edge: The edge to remove the border from.
     */
    public func removeBorder(edge: UIRectEdge) {
        if edge == .all {
            self.borderColor = nil
            self.borderWidth = 0
            return
        }
        
        self.subviews.filter { $0.tag == edge.viewTag }.forEach { $0.removeFromSuperview() }
    }
}


// Used to tag borders views so they can be removed if desired.
private extension UIRectEdge {
    var viewTag: Int {
        switch self {
        case .top:
            return 9001
        case .bottom:
            return 9002
        case .left:
            return 9003
        case .right:
            return 9004
        default:
            fatalError("viewTag does not support rect edge: \(self)")
        }
    }
}
