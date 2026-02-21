//
//  FocusRecordListBasicCellLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/21.
//

import Foundation
import UIKit

class FocusRecordListBasicCellLayout {
    
    /// 内容内间距
    static var contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
    
    /// 头视图高度
    static var headerViewHeight = 60.0
    
    var width: CGFloat = 0.0
    
    let session: FocusSession
    
    init(session: FocusSession) {
        self.session = session
    }
    
    var cellSize: CGSize {
        let height = Self.contentPadding.verticalLength + Self.headerViewHeight
        return CGSize(width: width, height: height)
    }
    
}
