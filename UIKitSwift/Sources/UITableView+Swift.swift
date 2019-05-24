//
//  Copyright © 2019 Theis Holdings, LLC. All rights reserved.
//

import UIKit


public extension UITableView {
    
    /// Resizes the `tableHeaderView` based on its contents using autolayout.
    func layoutHeaderViewIfNeeded() {
        self.tableHeaderView = self.resizedView(self.tableHeaderView)
    }
    
    /// Resizes the `tableFooterView` based on its contents using autolayout.
    func layoutFooterViewIfNeeded() {
        self.tableFooterView = self.resizedView(self.tableFooterView)
    }
    
    fileprivate func resizedView(_ view: UIView?) -> UIView? {
        guard let view = view else {
            return nil
        }
        
        view.layoutIfNeeded()
        let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        var frame = view.frame
        frame.size.height = height
        view.frame = frame
        
        return view
    }
}
