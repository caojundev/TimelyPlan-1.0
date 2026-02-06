//
//  TPStackView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/26.
//

import Foundation
import UIKit

class TPStackView: UIView {
    
    /// 条目间隔
    var itemMargin = 0.0
    
    /// 最小条目宽度
    var minimumItemWidth: CGFloat = 0.0

    /// 最大条目宽度
    var maximumItemWidth: CGFloat = .greatestFiniteMagnitude
    
    /// 固定的条目尺寸
    var fixedItemSize: CGSize?
    
    /// 内容视图
    let contentView = UIScrollView()

    /// 视图
    var views: [UIView]? {
        didSet {
            contentView.removeAllSubviews()
            guard let views = views else {
                return
            }
            
            for view in views {
                contentView.addSubview(view)
            }
            
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        contentView.frame = layoutFrame
        
        guard let views = self.views, views.count > 0 else {
            contentView.contentSize = .zero
            return
        }
        
        let count = views.count
        let itemSize: CGSize
        if let fixedItemSize = fixedItemSize {
            itemSize = fixedItemSize
        } else {
            let viewWidth = min(max(layoutFrame.width / CGFloat(count), minimumItemWidth), maximumItemWidth)
            itemSize = CGSize(width: viewWidth, height: layoutFrame.height)
        }
        
        var left = (layoutFrame.width - CGFloat(count) * itemSize.width - CGFloat(count - 1) * itemMargin) / 2.0
        left = max(0.0, left)
        for view in views {
            view.size = itemSize
            view.centerY = layoutFrame.height / 2.0
            view.left = left
            left = view.right
        }

        let contentSize = CGSize(width: left, height: layoutFrame.height)
        contentView.contentSize = contentSize
    }
    
}
