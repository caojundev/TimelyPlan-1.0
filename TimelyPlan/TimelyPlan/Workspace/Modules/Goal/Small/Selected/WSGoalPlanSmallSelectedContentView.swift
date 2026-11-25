//
//  WSGoalPlanSmallSelectedContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 目标计划·小·自选的内容视图。
///
/// 展示内容与目标计划列表一致：左侧色条与名称、日期区间、进度百分比、状态胶囊、进度条。
class WSGoalPlanSmallSelectedContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 16.0)
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 15.0)
        
        /// 日期区间字号
        static let intervalFont = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        
        /// 进度百分比字号
        static let progressFont = UIFont.monospacedDigitSystemFont(ofSize: 20.0, weight: .semibold)
        
        /// 状态胶囊字号
        static let statusFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)
        
        /// 状态胶囊内边距
        static let statusEdgeInsets = UIEdgeInsets(horizontal: 6.0, vertical: 4.0)
        
        /// 标题最大行数
        static let titleMaxLines = 2
        
        /// 左侧色条宽度及其与标题的间距
        static let colorBarWidth: CGFloat = 3.0
        static let colorBarSpacing: CGFloat = 8.0
        
        /// 进度条高度
        static let progressBarHeight: CGFloat = 8.0
        
        /// 文本行之间的间距
        static let contentSpacing: CGFloat = 6.0
        
        /// 底部信息与进度条的间距
        static let bottomSpacing: CGFloat = 10.0
    }
    
    /// 左侧色条
    private let colorView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.textColor = .label
        label.numberOfLines = Metrics.titleMaxLines
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    /// 日期区间
    private lazy var intervalLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.intervalFont
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    /// 进度百分比
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.progressFont
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    /// 状态胶囊
    private lazy var statusLabel: TPLabel = {
        let label = TPLabel()
        label.font = Metrics.statusFont
        label.textColor = .white
        label.textAlignment = .center
        label.edgeInsets = Metrics.statusEdgeInsets
        return label
    }()
    
    /// 进度条
    private lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.isUserInteractionEnabled = false
        view.cornerRadius = .greatestFiniteMagnitude
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(colorView)
        addSubview(titleLabel)
        addSubview(intervalLabel)
        addSubview(progressLabel)
        addSubview(statusLabel)
        addSubview(progressView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        /// 进度条贴底
        progressView.frame = CGRect(x: layoutFrame.minX,
                                    y: layoutFrame.maxY - Metrics.progressBarHeight,
                                    width: layoutFrame.width,
                                    height: Metrics.progressBarHeight)
        
        /// 底部行：进度百分比贴左，状态胶囊贴右，二者垂直居中
        let statusSize = statusLabel.sizeThatFits(.unlimited)
        statusLabel.size = CGSize(width: min(statusSize.width, layoutFrame.width),
                                  height: statusSize.height)
        statusLabel.right = layoutFrame.maxX
        statusLabel.layer.cornerRadius = statusLabel.halfHeight
        
        let progressSize = progressLabel.sizeThatFits(.unlimited)
        progressLabel.size = CGSize(width: min(progressSize.width,
                                               max(statusLabel.left - Metrics.contentSpacing - layoutFrame.minX, 0.0)),
                                    height: progressSize.height)
        progressLabel.left = layoutFrame.minX
        
        let rowHeight = max(statusLabel.height, progressLabel.height)
        let rowTop = progressView.top - Metrics.bottomSpacing - rowHeight
        statusLabel.top = rowTop + (rowHeight - statusLabel.height) / 2.0
        progressLabel.top = rowTop + (rowHeight - progressLabel.height) / 2.0
        
        /// 日期区间贴在底部行上方，无文案时不占高度
        let intervalHeight = intervalLabel.text?.isEmpty == false ? ceil(intervalLabel.font.lineHeight) : 0.0
        intervalLabel.frame = CGRect(x: layoutFrame.minX,
                                     y: rowTop - Metrics.contentSpacing - intervalHeight,
                                     width: layoutFrame.width,
                                     height: intervalHeight)
        
        /// 标题占据顶部剩余空间，最多两行
        let titleLeft = layoutFrame.minX + Metrics.colorBarWidth + Metrics.colorBarSpacing
        let titleWidth = max(layoutFrame.maxX - titleLeft, 0.0)
        let availableHeight = max(intervalLabel.top - Metrics.contentSpacing - layoutFrame.minY, 0.0)
        let maxTitleHeight = CGFloat(Metrics.titleMaxLines) * ceil(titleLabel.font.lineHeight)
        let titleSize = titleLabel.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude))
        let titleHeight = min(min(titleSize.height, maxTitleHeight), availableHeight)
        titleLabel.frame = CGRect(x: titleLeft,
                                  y: layoutFrame.minY,
                                  width: titleWidth,
                                  height: titleHeight)
        
        /// 色条与标题首行等高
        colorView.frame = CGRect(x: layoutFrame.minX,
                                 y: layoutFrame.minY,
                                 width: Metrics.colorBarWidth,
                                 height: min(ceil(titleLabel.font.lineHeight), titleHeight))
        colorView.layer.cornerRadius = Metrics.colorBarWidth / 2.0
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSGoalPlanDataItem else {
            colorView.backgroundColor = nil
            titleLabel.text = nil
            intervalLabel.text = nil
            progressLabel.text = nil
            statusLabel.text = nil
            statusLabel.layer.backgroundColor = nil
            progressView.setProgress(0.0, animated: false)
            setNeedsLayout()
            return
        }
        
        colorView.backgroundColor = dataItem.color
        titleLabel.text = dataItem.title
        intervalLabel.text = dataItem.intervalText
        progressLabel.text = dataItem.progressText
        statusLabel.text = dataItem.statusText
        statusLabel.layer.backgroundColor = dataItem.statusColor.cgColor
        progressView.barForeColor = dataItem.color
        progressView.barBackColor = dataItem.color.withAlphaComponent(0.2)
        progressView.setProgress(dataItem.progress, animated: false)
        
        /// 状态文案变化会改变胶囊宽度，需要重新布局
        setNeedsLayout()
    }
}
