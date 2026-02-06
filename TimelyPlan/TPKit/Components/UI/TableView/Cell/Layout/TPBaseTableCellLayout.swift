//
//  TPBaseTableCellLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit

class TPBaseTableCellLayout {

    /// 单元格默认高度
    static let defaultHeight = 55.0
    
    /// 单元格高度
    var height: CGFloat {
        get {
            if autoResizable {
                layoutIfNeeded()
            }
            
            return _height
        }
        
        set {
            _height = newValue
        }
    }

    /// 是否自适应尺寸
    var autoResizable: Bool = false {
        didSet {
            if autoResizable != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 单元格宽度
    var cellWidth: CGFloat? {
        didSet {
            if cellWidth != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 单元格内间距
    var cellPadding: UIEdgeInsets {
        /// 根据附件类型更新单元格内间距
        if accessoryType == .disclosureIndicator {
            return UIEdgeInsets(right: 32)
        }
            
        return .zero
    }
    
    /// 内容内间距
    var contentPadding = TableCellLayout.withoutAccessoryContentPadding {
        didSet {
            if contentPadding != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 附件类型
    var accessoryType: UITableViewCell.AccessoryType = .none {
        didSet {
            if accessoryType != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 最小高度
    var minimumHeight: CGFloat = 0.0 {
        didSet {
            if minimumHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 最大高度
    var maximumHeight: CGFloat = .greatestFiniteMagnitude {
        didSet {
            if maximumHeight != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 左侧视图尺寸
    var leftViewSize: CGSize = .zero {
        didSet {
            if leftViewSize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 左侧视图外间距
    var leftViewMargins: UIEdgeInsets = .zero {
        didSet {
            if leftViewMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 右侧视图尺寸
    var rightViewSize: CGSize = .zero {
        didSet {
            if rightViewSize != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 右侧视图外间距
    var rightViewMargins: UIEdgeInsets = .zero {
        didSet {
            if rightViewMargins != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 是否需要计算布局
    private var _shouldLayout: Bool = true
    
    /// 计算高度
    private var _height: CGFloat = TableCellLayout.defaultHeight
    
    /// 中间内容布局宽度
    func avaliableLayoutWidth() -> CGFloat {
        guard let cellWidth = cellWidth else {
            return 0.0
        }

        var contentWidth = cellWidth - cellPadding.horizontalLength - contentPadding.horizontalLength
        contentWidth = contentWidth - leftViewSize.width - leftViewMargins.horizontalLength
        contentWidth = contentWidth - rightViewSize.width - rightViewMargins.horizontalLength
        return contentWidth
    }
    
    func shouldLayout() -> Bool {
        return _shouldLayout
    }
    
    func setNeedsLayout() {
        _shouldLayout = true
    }
    
    func layoutIfNeeded() {
        guard _shouldLayout else {
            return
        }
        
        layout()
    }
    
    func layout() {
        _shouldLayout = false
        var contentHeight = getContentHeight()
        contentHeight += contentPadding.verticalLength
        _height = max(min(maximumHeight, contentHeight), minimumHeight)
    }
    
    func getContentHeight() -> CGFloat {
        return 0.0
    }
}
