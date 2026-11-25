//
//  WSTodoFilterRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 待办过滤器行视图。
///
/// 内容由 `TPColorInfoTextValueView` 承载：左侧为过滤器颜色竖条，右侧为过滤器名称与未完成任务数目；
/// 没有对应过滤器的行展示骨架。
class WSTodoFilterRowView: WSRowView, WSTodoRowViewUpdating {
    
    /// 行尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        
        /// 颜色竖条尺寸及其与名称的间距。与待办首页过滤器保持一致
        static let colorBarSize = CGSize(width: 6.0, height: 16.0)
        static let colorBarMargins = UIEdgeInsets(left: 2.0, right: 8.0)
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 当前展示的过滤器
    private(set) var dataItem: WSTodoFilterDataItem?
    
    /// 内容与行边缘的间距
    var contentInsets: UIEdgeInsets = Metrics.contentInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 点击行的回调
    var didSelectFilterHandler: ((WSTodoFilterDataItem) -> Void)?
    
    /// 颜色 + 名称
    let contentView = TPColorInfoTextValueView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        
        let titleConfig = TPLabelConfig.withFont(Metrics.titleFont,
                                                 textColor: .label,
                                                 adjustsFontSizeToFitWidth: true,
                                                 minimumScaleFactor: 0.8)
        contentView.titleConfig = titleConfig
        
        /// 颜色竖条不参与骨架，名称以胶囊块占位
        contentView.colorView.isSkeletonExcluded = true
        contentView.titleLabel.isSkeletonable = true
        contentView.titleLabel.skeletonShape = .capsule
        contentView.titleLabel.skeletonWidthRatio = 0.5
        
        /// 组件底色偏亮，骨架块需要更明显的对比
        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Metrics.skeletonColor
        self.skeletonConfig = skeletonConfig
        
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: contentInsets)
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        contentView.frame = layoutFrame
    }
    
    /// 颜色配置：竖条尺寸固定，颜色随过滤器变化
    private func updateColorConfig() {
        let config = TPColorAccessoryConfig()
        config.color = dataItem?.color
        config.size = Metrics.colorBarSize
        config.margins = Metrics.colorBarMargins
        contentView.colorConfig = config
    }
    
    // MARK: - 渲染
    /// 内容视图按通用数据类型刷新行
    func update(with dataItem: WSPluginDataItem?) {
        update(withFilter: dataItem as? WSTodoFilterDataItem)
    }
    
    /// 更新展示的过滤器。传 nil 时清空内容并展示骨架
    func update(withFilter dataItem: WSTodoFilterDataItem?) {
        self.dataItem = dataItem
        
        updateColorConfig()
        
        guard let dataItem = dataItem else {
            contentView.title = nil
            contentView.valueConfig = nil
            
            /// 骨架态保留名称一行高度，Skeleton 才能生成文本占位块
            contentView.titleMinimumHeight = ceil(contentView.titleConfig.font.lineHeight)
            
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        contentView.titleMinimumHeight = 0.0
        contentView.title = dataItem.title
        updateValue(for: dataItem)
        setNeedsLayout()
    }
    
    /// 任务数目：优先使用 `TodoCountFetcher` 的缓存，未缓存时取数完成后补上
    private func updateValue(for dataItem: WSTodoFilterDataItem) {
        contentView.valueConfig = nil
        
        guard let filter = dataItem.filter else {
            return
        }
        
        TodoCountFetcher.shared.fetchCount(for: filter) { [weak self] count in
            /// 回调时行可能已复用为其它过滤器
            guard let self = self, self.dataItem?.filterIdentifier == dataItem.filterIdentifier else {
                return
            }
            
            let config: TPTextAccessoryConfig? = count > 0 ? .valueText("\(count)") : nil
            self.contentView.valueConfig = config
            self.setNeedsLayout()
        }
    }
    
    // MARK: - 交互
    /// 点击行。没有对应过滤器时（空白行）不响应
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectFilterHandler?(dataItem)
    }
}
