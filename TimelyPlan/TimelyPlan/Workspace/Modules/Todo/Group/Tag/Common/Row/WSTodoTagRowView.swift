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
/// 内容由 `TPColorInfoTextValueView` 承载：左侧为标签颜色圆点，右侧为标签名称与未完成任务数目。
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
    /// 更新展示的标签。传 nil 时清空内容
    func update(withTag dataItem: WSTodoTagDataItem?) {
        self.dataItem = dataItem
        
        updateColorConfig()
        
        guard let dataItem = dataItem else {
            contentView.title = nil
            contentView.valueConfig = nil
            return
        }
        
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
    /// 点击行。没有对应标签时不响应
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectTagHandler?(dataItem)
    }
}
