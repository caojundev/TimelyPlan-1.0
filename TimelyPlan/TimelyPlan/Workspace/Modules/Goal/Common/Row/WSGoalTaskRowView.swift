//
//  WSGoalTaskRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 行视图基类

/// 目标任务行视图基类。
///
/// 收拢目标任务行共有的数据与交互：持有行数据、点击回调、内容间距与骨架配置；
/// 子类只负责搭建并更新各自的展示内容。
class WSGoalTaskRowView: WSRowView {
    
    /// 行共有尺寸
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 当前展示的目标任务
    private(set) var dataItem: WSGoalTaskDataItem?
    
    /// 内容与行边缘的间距
    var contentInsets: UIEdgeInsets = Metrics.contentInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 点击行的回调
    var didSelectTaskHandler: ((WSGoalTaskDataItem) -> Void)?
    
    /// 点击完成状态的回调
    var didClickCheckboxHandler: ((WSGoalTaskDataItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        
        /// 组件底色偏亮，骨架块需要更明显的对比
        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Metrics.skeletonColor
        self.skeletonConfig = skeletonConfig
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 数据
    /// 更新展示的目标任务。子类覆写后渲染各自内容，并调用 super 保留数据
    ///
    /// 传 nil 时由子类切换为骨架展示。
    func update(with dataItem: WSGoalTaskDataItem?) {
        self.dataItem = dataItem
    }
    
    // MARK: - 交互
    /// 点击行。没有对应目标任务时（空白行）不响应
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectTaskHandler?(dataItem)
    }
}
