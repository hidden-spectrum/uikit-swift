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

import JGProgressHUD


/// A wrapper class for JGProgressHUD that manages showing/hiding the HUD globally. It keeps an
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
    private static var progressHud = JGProgressHUD(style: .dark)
    
    // MARK: Lifecycle
    
    private init() {
    }
    
    /// Configures `UniversalProgressHUD` wrapper with the given HUD.
    ///
    /// - Note: This should only be called once before use.
    ///
    /// - Parameters:
    ///     - progressHud: The `JGProgressHUD` to use.
    public static func configure(with progressHud: JGProgressHUD) {
        self.progressHud = progressHud
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
        
        self.progressHud.show(in: mainWindow)
        
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
        self.progressHud.dismiss()
        
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
