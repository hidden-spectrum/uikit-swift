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

import os.log
import UIKit


/// Adds convenience methods for observing the keyboard showing/hiding. This wraps the `UIResponder`
/// notifications and makes it easy to work with the notification `userInfo` by wrapping the
/// information in the `KeyboardPresentationInfo` type.
public protocol KeyboardPresentationObserver {
    
    /// Sets the handler to call when the keyboard is about to show.
    /// - Note: There can only be one `willShow` handler at a time.
    /// - Warning: To prevent retain cycles, you must declare `[weak self]` in your block.
    func setKeyboardWillShowHandler(_ block: @escaping KeyboardPresentationInfoBlock)
    
    /// Sets the handler to call when the keyboard frame is about to change.
    /// - Note: There can only be one `frameWillChange` handler at a time.
    /// - Warning: To prevent retain cycles, you must declare `[weak self]` in your block.
    func setKeyboardWillChangeFrameHandler(_ block: @escaping KeyboardPresentationInfoBlock)
    
    /// Sets the handler to call when the keyboard is about to hide.
    /// - Note: There can only be one `willHide` handler at a time.
    /// - Warning: To prevent retain cycles, you must declare `[weak self]` in your block.
    func setKeyboardWillHideHandler(_ block: @escaping KeyboardPresentationInfoBlock)
    
    /// Removes the keyboard presentation handlers. Call this in your `deinit` to ensure
    /// notifications are no observed.
    func removeKeyboardPresentationHandlers()
}

public extension KeyboardPresentationObserver {
    func setKeyboardWillShowHandler(_ block: @escaping KeyboardPresentationInfoBlock) {
        self.setKeyboardObserver(for: UIResponder.keyboardWillShowNotification, storeNotificationTokenUsingAssociationKey: &.willShow, handler: block)
    }
    
    func setKeyboardWillChangeFrameHandler(_ block: @escaping KeyboardPresentationInfoBlock) {
        self.setKeyboardObserver(for: UIResponder.keyboardWillChangeFrameNotification, storeNotificationTokenUsingAssociationKey: &.willChange, handler: block)
    }
    
    func setKeyboardWillHideHandler(_ block: @escaping KeyboardPresentationInfoBlock) {
        self.setKeyboardObserver(for: UIResponder.keyboardWillHideNotification, storeNotificationTokenUsingAssociationKey: &.willHide, handler: block)
    }
    
    func removeKeyboardPresentationHandlers() {
        self.removeKeyboardObserver(usingNotificationTokenStoredWithAssociationKey: &.willShow)
        self.removeKeyboardObserver(usingNotificationTokenStoredWithAssociationKey: &.willChange)
        self.removeKeyboardObserver(usingNotificationTokenStoredWithAssociationKey: &.willHide)
    }
    
    private func setKeyboardObserver(
        for notificationName: Notification.Name,
        storeNotificationTokenUsingAssociationKey associationKey: UnsafePointer<KeyboardNotificationTokenAssociationKey>,
        handler: @escaping KeyboardPresentationInfoBlock
    ) {
        self.removeKeyboardObserver(usingNotificationTokenStoredWithAssociationKey: associationKey)
        
        let notificationToken = NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { (notification) in
            guard let keyboardInfo = self.keyboardInfo(from: notification) else {
                os_log("Notification missing keyboard information: %{public}@", log: .uiKitSwift, type: .error, notification.debugDescription)
                return
            }
            handler(keyboardInfo)
        }
        objc_setAssociatedObject(self, associationKey, notificationToken, .OBJC_ASSOCIATION_RETAIN)
    }
    
    private func keyboardInfo(from notification: Notification) -> KeyboardPresentationInfo? {
        guard let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {
            return nil
        }
        return KeyboardPresentationInfo(frameEndRect: endFrameValue.cgRectValue, animationDuration: animationDuration)
    }
    
    private func removeKeyboardObserver(usingNotificationTokenStoredWithAssociationKey associationKey: UnsafePointer<KeyboardNotificationTokenAssociationKey>) {
        guard let notificationToken = objc_getAssociatedObject(self, associationKey) as? NSObjectProtocol else {
            return
        }
        NotificationCenter.default.removeObserver(notificationToken)
    }
}


public struct KeyboardPresentationInfo {
    public let frameEndRect: CGRect
    public let animationDuration: TimeInterval
}

public typealias KeyboardPresentationInfoBlock = ((KeyboardPresentationInfo) -> Void)


private class KeyboardNotificationTokenAssociationKey {
    static var willShow = KeyboardNotificationTokenAssociationKey()
    static var willChange = KeyboardNotificationTokenAssociationKey()
    static var willHide = KeyboardNotificationTokenAssociationKey()
}
