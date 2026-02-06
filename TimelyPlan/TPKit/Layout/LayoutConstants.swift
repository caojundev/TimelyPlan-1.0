//
//  LayoutConstants.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/25.
//

import Foundation
import UIKit

struct TableCellLayout {

    /// 单元格默认高度
    static let defaultHeight = 55.0

    /// 无附件视图时单元格内间距
    static let withoutAccessoryCellPadding = UIEdgeInsets.zero
    
    /// 有附件视图时单元格内间距
    static let withAccessoryCellPadding = UIEdgeInsets(right: 32.0)

    /// 无附件视图时内容内间距
    static let withoutAccessoryContentPadding = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
    
    /// 设置附件视图时内容内间距
    static let withAccessoryContentPadding = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 5.0)
}
