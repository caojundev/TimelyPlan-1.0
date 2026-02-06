//
//  TPSheetMenuTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/4.
//

import Foundation
import UIKit

class TPSheetMenuTableCell: TPImageInfoTableCell {

    /// 按钮动作
    var menuAction: TPMenuAction? {
        didSet {
            self.infoView.title = menuAction?.title
            self.imageContent = .withImage(menuAction?.image)
            self.setNeedsLayout()
        }
    }
    
}
