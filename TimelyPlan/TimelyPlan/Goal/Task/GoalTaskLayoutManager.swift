//
//  GoalTaskLayoutManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/3.
//

import Foundation
import UIKit

/// 目标任务布局配置
struct GoalTaskLayoutConfig: Equatable {
    
    /// 内间距
    var padding: UIEdgeInsets = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
    
    /// 最小高度
    var minimumHeight: CGFloat = 60.0
    
    /// 复选框配置
    var checkboxConfig: TodoTaskCheckboxConfig = .normal
    
    /// 复选框外间距
    var checkboxMargins: UIEdgeInsets = UIEdgeInsets(right: 10.0)
    
    /// 更多按钮尺寸
    var moreButtonSize: CGSize = CGSize(width: 24.0, height: 24.0)
    
    /// 更多按钮外间距
    var moreButtonMargins: UIEdgeInsets = UIEdgeInsets(left: 10.0)
    
    /// 名称字体
    var nameFont: UIFont = UIFont.boldSystemFont(ofSize: 15.0)
    
    /// 最大名称行数目
    var nameLinesCount: Int = 0
    
    /// 详情顶部间距
    var detailTopMargin: CGFloat = 5.0
    
    /// 详情字体
    var detailFont: UIFont = UIFont.systemFont(ofSize: 11.0)
    
    /// 最大详情行数目
    var detailLinesCount: Int = 0
    
    /// 控制可以显示进度条
    var canShowProgress: Bool = true
    
    /// 进度条顶部间距
    var progressTopMargin: CGFloat = 6.0
    
    /// 进度条高度
    var progressHeight: CGFloat = 2.0
}

/// 目标任务布局管理器
class GoalTaskLayoutManager {
    
    /// 约束宽度
    var width: CGFloat = 0.0
    
    /// 布局配置信息
    var config = GoalTaskLayoutConfig()
    
    /// 布局缓存字典
    private var layouts: [String: GoalTaskInfoLayout] = [:]
    
    /// 获取目标任务对应的布局对象
    func layout(for task: GoalTask) -> GoalTaskInfoLayout {
        let identifier = task.identifier
        var layout = layouts[identifier]
        if layout == nil || !task.isEqual(layout?.task) {
            layout = GoalTaskInfoLayout(task: task)
            layouts[identifier] = layout
        }
        
        layout?.width = width
        layout?.config = config
        layout?.layoutIfNeeded()
        return layout!
    }
    
    /// 标记需要重新布局
    func setNeedsLayout(for tasks: [GoalTask]) {
        for task in tasks {
            let layout = layouts[task.identifier]
            layout?.setNeedsLayout()
        }
    }
    
    /// 标记单个任务需要重新布局
    func setNeedsLayout(for task: GoalTask) {
        let layout = layouts[task.identifier]
        layout?.setNeedsLayout()
    }
    
    /// 移除任务的布局缓存
    func removeLayout(for tasks: [GoalTask]) {
        for task in tasks {
            layouts.removeValue(forKey: task.identifier)
        }
    }
    
    /// 移除所有布局缓存
    func removeAllLayouts() {
        layouts.removeAll()
    }
}

/// 目标任务布局信息
class GoalTaskInfoLayout {
    
    /// 约束宽度
    var width: CGFloat = 0.0 {
        didSet {
            if width != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 尺寸
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    /// 布局配置信息
    var config: GoalTaskLayoutConfig = GoalTaskLayoutConfig() {
        didSet {
            if config != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 高度
    private(set) var height: CGFloat = 0.0
    
    /// 名称高度
    private(set) var nameHeight: CGFloat = 40.0
    
    /// 详情高度
    private(set) var detailHeight: CGFloat = 30.0
    
    /// 进度（0~1）
    private(set) var progress: CGFloat = 0.0
    
    /// 进度条是否隐藏
    var isProgressHidden: Bool {
        return !(config.canShowProgress && task.targetValue > 0)
    }
    
    /// 详情文本
    private(set) var detailText: String = ""
    
    /// 目标任务
    let task: GoalTask
    
    /// 是否需要布局
    private var _shouldLayout: Bool = true
    
    init(task: GoalTask) {
        self.task = task
    }
    
    func setNeedsLayout() {
        _shouldLayout = true
    }
    
    private var shouldLayout: Bool {
        return _shouldLayout
    }
    
    func layoutIfNeeded() {
        guard shouldLayout else {
            return
        }
        
        layout()
    }
    
    /// 计算布局
    func layout() {
        let checkboxLength = config.checkboxConfig.size.width + config.checkboxMargins.horizontalLength
        let moreButtonLength = config.moreButtonSize.width + config.moreButtonMargins.horizontalLength
        let labelWidth = width - config.padding.horizontalLength - checkboxLength - moreButtonLength
        guard labelWidth > 0 else {
            return
        }
        
        /// 计算名称高度
        let nameSize: CGSize = .boundingSize(string: task.name,
                                             font: config.nameFont,
                                             constraintWidth: labelWidth,
                                             linesCount: config.nameLinesCount)
        self.nameHeight = nameSize.height
        
        /// 构建详情文本
        self.detailText = GoalTaskInfoLayout.detailText(for: task)
        let detailSize: CGSize = .boundingSize(string: detailText,
                                               font: config.detailFont,
                                               constraintWidth: labelWidth,
                                               linesCount: config.detailLinesCount)
        self.detailHeight = detailSize.height
        
        /// 计算进度
        let targetValue = task.targetValue
        if targetValue > 0 {
            let value = CGFloat(task.initialValue) / CGFloat(targetValue)
            self.progress = min(max(value, 0.0), 1.0)
        } else {
            self.progress = 0.0
        }
        
        var contentHeight = config.padding.verticalLength + nameHeight
        if detailHeight > 0.0 {
            contentHeight += config.detailTopMargin + detailHeight
        }
        
        if !isProgressHidden {
            contentHeight += config.progressTopMargin + config.progressHeight
        }
        
        self.height = max(contentHeight, config.minimumHeight)
        _shouldLayout = false
    }
    
    /// 构建详情文本
    private static func detailText(for task: GoalTask) -> String {
        var components = [String]()
        
        /// 数值进度
        components.append("\(task.initialValue)/\(task.targetValue)")
        
        /// 记录方式
        components.append(task.recordType.title)
        
        /// 计算方式
        components.append(task.calculation.title)
        
        /// 权重
        if task.weight > 0 {
            components.append(String(format: resGetString("Weight %ld"), task.weight))
        }
        
        return components.joined(separator: " • ")
    }
}
