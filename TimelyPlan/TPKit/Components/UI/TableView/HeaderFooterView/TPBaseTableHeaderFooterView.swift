//
//  TPBaseTableHeaderFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/8.
//

import Foundation
import UIKit

class TPBaseTableHeaderFooterItem {
    
    /// 区块头脚视图注册类
    var registerClass: TPBaseTableHeaderFooterView.Type = TPBaseTableHeaderFooterView.self
    
    /// 内间距
    var padding: UIEdgeInsets = UIEdgeInsets(horizontal: 16.0)
    
    /// 高度
    var height: CGFloat = 0.0
}

class TPBaseTableHeaderFooterView: UITableViewHeaderFooterView {
    
    /// 数据条目
    var headerFooterItem: TPBaseTableHeaderFooterItem? {
        didSet {
            contentView.padding = headerFooterItem?.padding ?? .zero
            setNeedsLayout()
        }
    }
    
    /// 单元格代理对象
    weak var delegate: AnyObject?
    
    /// 左侧视图
    var leftView: UIView? {
        didSet {
            if leftView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let leftView = leftView {
                contentView.addSubview(leftView)
            }
            
            setNeedsLayout()
        }
    }
 
    /// 左侧视图尺寸
    var leftViewSize: CGSize = .zero
    
    /// 左侧视图外间距
    var leftViewMargins: UIEdgeInsets = .zero
    
    /// 右侧视图
    var rightView: UIView? {
        didSet {
            if rightView !== oldValue {
                oldValue?.removeFromSuperview()
            }
            
            if let rightView = rightView {
                contentView.addSubview(rightView)
            }
            
            setNeedsLayout()
        }
    }
 
    /// 右侧视图尺寸
    var rightViewSize: CGSize = .zero
    
    /// 右侧视图外间距
    var rightViewMargins: UIEdgeInsets = .zero
    
    var contentPadding: UIEdgeInsets {
        get {
            return contentView.padding
        }
        
        set {
            contentView.padding = newValue
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupContentSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLeftView()
        layoutRightView()
    }
    
    /// 布局左视图
    func layoutLeftView() {
        guard let leftView = leftView else {
            return
        }

        let layoutFrame = contentView.layoutFrame()
        leftView.size = leftViewSize
        leftView.left = layoutFrame.minX + leftViewMargins.left
        leftView.centerY = layoutFrame.midY
    }
    
    /// 布局右视图
    func layoutRightView() {
        guard let rightView = rightView else {
            return
        }
        
        let layoutFrame = contentView.layoutFrame()
        rightView.size = rightViewSize
        rightView.right = layoutFrame.maxX - rightViewMargins.right
        rightView.centerY = layoutFrame.midY
    }
    
    /// 当前可用的布局区域
    func availableLayoutFrame() -> CGRect {
        let insets = UIEdgeInsets(left: leftViewSize.width + leftViewMargins.horizontalLength,
                                  right: rightViewSize.width + rightViewMargins.horizontalLength)
        return contentView.layoutFrame().inset(by: insets)
    }
    
    
    // MARK: - 初始化内容子视图
    func setupContentSubviews() {
        
    }
}
