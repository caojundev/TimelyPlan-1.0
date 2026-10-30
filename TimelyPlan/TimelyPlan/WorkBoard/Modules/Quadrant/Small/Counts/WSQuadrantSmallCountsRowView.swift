//
//  WSQuadrantSmallCountsRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 象限行视图

/// 四象限·小·数量的行视图。承载标识点、象限名称与未完成任务数。
class WSQuadrantSmallCountsRowView: WSQuadrantCountsRowView {
    
    /// 象限卡片
    private let itemView = WSQuadrantSmallCountsItemView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        /// 卡片不参与交互，点击统一由行视图处理
        itemView.isUserInteractionEnabled = false
        addSubview(itemView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        itemView.frame = bounds
    }
    
    // MARK: - 渲染
    override func updateContent(with dataItem: WSQuadrantCountsItem?) {
        itemView.update(with: dataItem)
    }
}

// MARK: - 象限卡片

/// 四象限·小·数量的象限卡片。左上角为标识点与象限名称，左下角为未完成任务数。
class WSQuadrantSmallCountsItemView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与卡片边缘的间距
        static let padding = UIEdgeInsets(value: 6.0)
        
        /// 标识点尺寸
        static let dotSize = CGSize(value: 6.0)
        
        /// 标识点与名称的间距
        static let dotSpacing: CGFloat = 4.0
        
        /// 名称字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 11.0)
        
        /// 名称最多展示的行数
        static let titleMaximumLines: Int = 2
        
        /// 名称与数目的间距
        static let countSpacing: CGFloat = 2.0
        
        /// 数目字号占数目区域高度的比例及上限
        static let countFontRatio: CGFloat = 0.95
        static let countMaximumFontSize: CGFloat = 44.0
    }
    
    /// 标识点
    private lazy var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Metrics.dotSize.width / 2.0
        return view
    }()
    
    /// 象限名称
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.numberOfLines = Metrics.titleMaximumLines
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// 未完成任务数
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(dotView)
        addSubview(titleLabel)
        addSubview(countLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        let lineHeight = ceil(Metrics.titleFont.lineHeight)
        let titleMaximumHeight = lineHeight * CGFloat(Metrics.titleMaximumLines)
        let titleWidth = max(contentFrame.width - Metrics.dotSize.width - Metrics.dotSpacing, 0.0)
        let titleHeight = min(ceil(titleLabel.sizeThatFits(CGSize(width: titleWidth,
                                                                 height: titleMaximumHeight)).height),
                              titleMaximumHeight)
        
        /// 标识点与名称首行居中对齐
        dotView.size = Metrics.dotSize
        dotView.left = contentFrame.minX
        dotView.top = contentFrame.minY + (lineHeight - Metrics.dotSize.height) / 2.0
        
        titleLabel.size = CGSize(width: titleWidth, height: titleHeight)
        titleLabel.left = dotView.right + Metrics.dotSpacing
        titleLabel.top = contentFrame.minY
        
        /// 名称按固定行数预留高度，保证各卡片的数目区域大小一致
        let countTop = contentFrame.minY + titleMaximumHeight + Metrics.countSpacing
        let countHeight = max(contentFrame.maxY - countTop, 0.0)
        countLabel.size = CGSize(width: contentFrame.width, height: countHeight)
        countLabel.left = contentFrame.minX
        countLabel.top = countTop
        
        let fontSize = min(floor(countHeight * Metrics.countFontRatio), Metrics.countMaximumFontSize)
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: max(fontSize, 1.0), weight: .bold)
    }
    
    // MARK: - 渲染
    /// 更新象限与未完成任务数。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?) {
        guard let dataItem = dataItem else {
            dotView.backgroundColor = nil
            titleLabel.text = nil
            countLabel.text = nil
            setNeedsLayout()
            return
        }
        
        let color = dataItem.quadrant.color
        dotView.backgroundColor = color
        titleLabel.textColor = color
        titleLabel.text = dataItem.quadrant.title
        countLabel.textColor = color
        countLabel.text = "\(dataItem.count)"
        
        setNeedsLayout()
    }
}
