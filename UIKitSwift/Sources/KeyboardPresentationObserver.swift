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


/// Adds convenience methods for observing the keyboard showing/hiding. This wraps the `UIResponder`
/// notifications and makes it easy to work with the notification `userInfo` by wrapping the
/// information in the `KeyboardPresentationInfo` type.
public protocol KeyboardPresentationObserver {
    
    /// Sets the handler to call when the keyboard is about to show.
    /// - Note: There can only be one `willShow` handler at a time.
    /// - Warning: To prevent retain cycles, you must declare `[weak self]` in your block.
    func setKeyboardWillShowHandler(_ block: @escaping KeyboardPresentationInfoBlock)
    
    /// Sets the handler to call when the keyboard is about to hide.
    /// - Note: There can only be one `willHide` handler at a time.
    /// - Warning: To prevent retain cycles, you must declare `[weak self]` in your block.
    func setKeyboardWillHideHandler(_ block: @escaping KeyboardPresentationInfoBlock)
    
    /// Removes the keyboard presentation handlers. Call this in your `deinit` to ensure
    /// notifications are no observed.
    func removeKeyboardPresentationHandlers()
}

extension KeyboardPresentationObserver {
    func setKeyboardWillShowHandler(_ block: @escaping KeyboardPresentationInfoBlock) {
        self.setKeyboardObserver(for: UIResponder.keyboardWillShowNotification, handler: block)
    }
    
    func setKeyboardWillHideHandler(_ block: @escaping KeyboardPresentationInfoBlock) {
        self.setKeyboardObserver(for: UIResponder.keyboardWillHideNotification, handler: block)
    }
    
    func removeKeyboardPresentationHandlers() {
        self.removeKeyboardObserver(for: UIResponder.keyboardWillShowNotification)
        self.removeKeyboardObserver(for: UIResponder.keyboardWillHideNotification)
    }
    
    private func setKeyboardObserver(for notificationName: Notification.Name, handler: @escaping KeyboardPresentationInfoBlock) {
        self.removeKeyboardObserver(for: notificationName)
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { (notification) in
            guard let keyboardInfo = self.keyboardInfo(from: notification) else {
                os_log("Notification missing keyboard information: %{public}@", log: .uiKitSwift, type: .error, notification.debugDescription)
                return
            }
            handler(keyboardInfo)
        }
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
    
    private func removeKeyboardObserver(for notificationName: Notification.Name) {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
}


public struct KeyboardPresentationInfo {
    public let frameEndRect: CGRect
    public let animationDuration: TimeInterval
}

public typealias KeyboardPresentationInfoBlock = ((KeyboardPresentationInfo) -> Void)
