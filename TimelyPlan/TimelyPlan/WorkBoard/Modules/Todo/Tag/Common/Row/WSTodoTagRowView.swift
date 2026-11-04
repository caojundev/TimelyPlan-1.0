//
//  WSTodoTagRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 待办标签行视图。
///
/// 内容由 `TPColorInfoTextValueView` 承载：左侧为标签颜色圆点，右侧为标签名称与未完成任务数目；
/// 没有对应标签的行展示骨架。
class WSTodoTagRowView: WSRowView, WSTodoRowViewUpdating {
    
    /// 行尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        
        /// 颜色圆点尺寸及其与名称的间距
        static let colorDotSize = CGSize.size(2)
        static let colorDotMargins = UIEdgeInsets(left: 2.0, right: 8.0)
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 当前展示的标签
    private(set) var dataItem: WSTodoTagDataItem?
    
    /// 内容与行边缘的间距
    var contentInsets: UIEdgeInsets = Metrics.contentInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 点击行的回调
    var didSelectTagHandler: ((WSTodoTagDataItem) -> Void)?
    
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
        
        /// 颜色圆点不参与骨架，名称以胶囊块占位
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
    
    /// 颜色配置：圆点尺寸固定，颜色随标签变化
    private func updateColorConfig() {
        let config = TPColorAccessoryConfig()
        config.color = dataItem?.color
        config.size = Metrics.colorDotSize
        config.margins = Metrics.colorDotMargins
        contentView.colorConfig = config
    }
    
    // MARK: - 渲染
    /// 更新展示的标签。传 nil 时清空内容并展示骨架
    func update(withTag dataItem: WSTodoTagDataItem?) {
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
    private func updateValue(for dataItem: WSTodoTagDataItem) {
        contentView.valueConfig = nil
        
        guard let tag = dataItem.tag else {
            return
        }
        
        TodoCountFetcher.shared.fetchCount(for: tag) { [weak self] count in
            /// 回调时行可能已复用为其它标签
            guard let self = self, self.dataItem?.tagIdentifier == dataItem.tagIdentifier else {
                return
            }
            
            let config: TPTextAccessoryConfig? = count > 0 ? .valueText("\(count)") : nil
            self.contentView.valueConfig = config
            self.setNeedsLayout()
        }
    }
    
    /// 内容视图按通用数据类型刷新行
    func update(with dataItem: WSPluginDataItem?) {
        update(withTag: dataItem as? WSTodoTagDataItem)
    }
    
    // MARK: - 交互
    /// 点击行。没有对应标签时（空白行）不响应
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectTagHandler?(dataItem)
    }
}
