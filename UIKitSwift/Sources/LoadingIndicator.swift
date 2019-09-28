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


/// A wrapper class for LoadingIndicator that manages showing/hiding the indicator globally. It keeps an
/// internal stack so that multiple show / dismiss calls do not prematurely remove the HUD.
public struct UniversalLoadingIndicator {
    
    // MARK: Public
    
    /// - Returns: Whether the global HUD is currently visible or not.
    public static var isVisible: Bool {
        return self.stackCount > 0
    }
    
    // MARK: Private
    
    private static var delayTimer: Timer?
    private static var stackCount: Int = 0
    private static var pendingShowCount: Int = 0
    private static var loadingIndicator = LoadingIndicator(style: .dark)
    
    // MARK: Lifecycle
    
    private init() {
    }
    
    /// Configures `UniversalProgressHUD` wrapper with the given HUD.
    ///
    /// - Note: This should only be called once before use.
    ///
    /// - Parameters:
    ///     - loadingIndicator: The `LoadingIndicator` to use.
    public static func configure(with loadingIndicator: LoadingIndicator) {
        self.loadingIndicator = loadingIndicator
    }
    
    // MARK: Show / Hide
    
    /// Shows the progress HUD on the main window after the given delay. This is useful if you want
    /// to give operations that may complete quickly a chance to avoid unecessary displaying of
    /// the HUD.
    ///
    /// - Warning: This method must always be paired with a call to `dismiss()` or the HUD may not
    /// be removed.
    ///
    /// - Note: If there is already a pending `showAfterDelay()` call, this will not change the
    /// previous delay.
    ///
    /// - Parameters:
    ///     - delay: How long should UniversalProgressHUD wait until displayed. Defaults to 0.5
    ///     seconds.
    public static func showAfterDelay(_ delay: TimeInterval = 0.5) {
        // If we already have a timer, just increase the number of "pending" HUDs
        guard self.delayTimer == nil else {
            self.pendingShowCount += 1
            return
        }
        
        self.delayTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in
            self.show(isFromDelayTimer: true)
        })
        
        self.pendingShowCount += 1
    }
    
    /// Shows a progress HUD on the main window. If already showing, then the same instance is used.
    ///
    /// - Warning: This method must always be paired with a call to `dismiss()` or the HUD may not
    /// be removed.
    public static func show() {
        self.show(isFromDelayTimer: false)
    }
    
    // Private implementation for show.
    private static func show(isFromDelayTimer: Bool) {
        self.cancelTimer()
        
        // If we're already showing, just add to stack count
        if self.stackCount > 0 {
            self.stackCount += 1
            return
        }
        
        guard let mainWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        self.loadingIndicator.show(in: mainWindow)
        
        // Increase the stack count by however many `show(afterDelay:)` calls there were. It doesn't
        // matter if isFromDelayTimer is true or false, we need to account for how many
        // HUDs would've been added to the "stack" as though `show()` had been called instead.
        self.stackCount += self.pendingShowCount
        self.pendingShowCount = 0
        
        // If this hasn't been called from the delayTimer, then it was requested to show immediately
        // so add + 1 to the stack for that call, which is separate from the pendingShowCount.
        if isFromDelayTimer == false {
            self.stackCount += 1
        }
    }
    
    /// Dismisses the progress HUD so long as the stack has been cleared.
    ///
    /// - Warning: This must always be paired with a call to `show()` or it may result in undefined
    /// behaviour.
    public static func dismiss() {
        
        // If we aren't showing, remove pending show counts or cancel timer.
        if self.stackCount == 0 {
            if self.pendingShowCount > 1 {
                self.pendingShowCount -= 1
            } else { // pendingShowCount == 0 or 1
                self.pendingShowCount = 0
                self.cancelTimer()
            }
            return
        }
        
        // If we haven't been dismissed enough times, don't hide yet.
        if self.stackCount > 1 {
            self.stackCount -= 1
            return
        }
        
        self.cancelTimer()
        self.loadingIndicator.dismiss()
        
        self.stackCount = 0
        self.pendingShowCount = 0
    }
    
    private static func cancelTimer() {
        guard let delayTimer = self.delayTimer else {
            return
        }
        
        delayTimer.invalidate()
        self.delayTimer = nil
    }
}


/// An instance loading indicator 
public final class LoadingIndicator: UIView {
    
    // MARK: Private
    
    private struct Defaults {
        static let animationDuration = 0.2
    }
    
    // MARK: Lifecycle
    
    @available(*, unavailable, message: "Use init(style:)")
    override init(frame: CGRect) {
        fatalError("This constructor is unavailable.")
    }
    
    public required init(style: UIBlurEffect.Style = .dark) {
        super.init(frame: CGRect.zero)
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let size = CGSize(width: 65.0, height: 65.0)
        blurEffectView.frame.size = size
        blurEffectView.center = CGPoint(x: self.center.x, y: self.center.y * 0.65)
        blurEffectView.layer.cornerRadius = 10
        blurEffectView.layer.masksToBounds = true
        blurEffectView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        blurEffectView.alpha = 0.85
        blurEffectView.borderWidth = 1.0 / UIScreen.main.scale
        blurEffectView.borderColor = style == .dark ? UIColor.black.withAlphaComponent(0.25) : .clear
        self.addSubview(blurEffectView)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = style == .dark ? .white : .black
        activityIndicator.sizeToFit()
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        activityIndicator.frame = CGRect(
            x: blurEffectView.frame.size.width / 2 - activityIndicator.frame.size.width / 2,
            y: blurEffectView.frame.size.height / 2 - activityIndicator.frame.size.height / 2,
            width: activityIndicator.frame.size.width,
            height: activityIndicator.frame.size.height
        )
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    @available(*, unavailable, message: "init(coder:) has not been implemented")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Display Control
    
    public func show(in view: UIView, animated: Bool = true) {
        self.alpha = 0
        
        self.frame = view.bounds
        view.addSubview(self)
        
        UIView.animate(withDuration: animated ? Defaults.animationDuration : 0, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    public func dismiss(animated: Bool = true) {
        guard animated else {
            self.removeFromSuperview()
            return
        }
        
        UIView.animate(withDuration: Defaults.animationDuration, delay: 0, options: .beginFromCurrentState, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
