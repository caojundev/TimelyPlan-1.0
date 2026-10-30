//
//  WSQuadrantCountsRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 象限行视图基类

/// 四象限·数目的行视图基类。
///
/// 统一处理卡片底色、按下高亮与点击回调，卡片内容由各尺寸的行视图自行搭建。
class WSQuadrantCountsRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 卡片圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 卡片底色透明度
        static let backgroundColorAlpha: CGFloat = 0.1
        
        /// 按下时卡片底色的透明度
        static let highlightedBackgroundColorAlpha: CGFloat = 0.2
    }
    
    /// 当前展示的象限数据
    private(set) var dataItem: WSQuadrantCountsItem?
    
    /// 点击象限回调
    var didSelectQuadrantHandler: ((Quadrant) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentCornerRadius = Metrics.cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 渲染
    /// 更新象限与未完成任务数。传 nil 时清空内容
    func update(with dataItem: WSQuadrantCountsItem?) {
        self.dataItem = dataItem
        updateContent(with: dataItem)
        
        let color = dataItem?.quadrant.color
        normalBackColor = color?.withAlphaComponent(Metrics.backgroundColorAlpha) ?? .clear
        highlightedBackColor = color?.withAlphaComponent(Metrics.highlightedBackgroundColorAlpha) ?? .clear
    }
    
    /// 更新卡片内容，子类覆写
    func updateContent(with dataItem: WSQuadrantCountsItem?) {
        
    }
    
    // MARK: - 交互
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectQuadrantHandler?(dataItem.quadrant)
    }
}
