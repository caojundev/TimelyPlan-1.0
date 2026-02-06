//
//  TodoTaskLayoutManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/12.
//

import Foundation
import UIKit

struct TodoTaskLayoutConfig: Equatable {
    
    /// 内间距
    var padding: UIEdgeInsets = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)

    /// 最小高度
    var minimumHeight: CGFloat = 60.0
    
    /// 复选框配置
    var checkboxConfig: TodoTaskCheckboxConfig = .normal
    
    /// 复选框外间距
    var checkboxMargins: UIEdgeInsets = UIEdgeInsets(right: 10.0)

    /// 名称字体
    var nameFont: UIFont = UIFont.boldSystemFont(ofSize: 15.0)
    
    /// 最大名称行数目
    var nameLinesCount: Int = 0

    /// 详情顶部间距
    var detailTopMargin: CGFloat = 5.0
    
    /// 详情字体
    var detailFont: UIFont = UIFont.boldSystemFont(ofSize: 10.0)
    
    /// 最大详情行数目
    var detailLinesCount: Int = 0
    
    /// 控制可以显示进度条
    var canShowProgress = true
    
    /// 进度条顶部高度
    var progressTopMargin = 6.0
    
    /// 进度条高度
    var progressHeight = 2.0
    
    static var normal: TodoTaskLayoutConfig {
        return TodoTaskLayoutConfig()
    }
    
    static var small: TodoTaskLayoutConfig {
        var config = TodoTaskLayoutConfig()
        config.padding = UIEdgeInsets(horizontal: 4.0, vertical: 5.0)
        config.minimumHeight = 36.0
        config.checkboxConfig = .small
        config.checkboxMargins = UIEdgeInsets(left: 2.0, right: 4.0)
        config.nameFont = UIFont.systemFont(ofSize: 12.0)
        config.nameLinesCount = 2
        config.detailTopMargin = 2.0
        config.detailFont = UIFont.systemFont(ofSize: 8.0)
        config.detailLinesCount = 1
        config.progressTopMargin = 2.0
        config.progressHeight = 2.0
        return config
    }
}

class TodoTaskLayoutManager {
    
    /// 约束宽度
    var width: CGFloat = 0.0
    
    /// 显示详情
    var showDetail: Bool = true
    
    /// 布局配置信息
    var config = TodoTaskLayoutConfig()

    /// 详细显示选项
    var detailOption: TodoTaskDetailOption = .allExceptList
    
    /// 布局缓存字典
    private var layouts: [String: TodoTaskInfoLayout] = [:]

    func layout(for task: TodoTask) -> TodoTaskInfoLayout {
        guard let identifier = task.identifier else {
            return TodoTaskInfoLayout(task: task)
        }
        
        var layout = layouts[identifier]
        if layout == nil {
            layout = TodoTaskInfoLayout(task: task)
            layouts[identifier] = layout
        }
        
        layout?.width = width
        layout?.detailOption = detailOption
        layout?.showDetail = showDetail
        layout?.config = config
        layout?.layoutIfNeeded()
        return layout!
    }
    
    func setNeedsLayout(for tasks: [TodoTask]) {
        for task in tasks {
            if let identifier = task.identifier {
                let layout = layouts[identifier]
                layout?.setNeedsLayout()
            }
        }
    }
    
    func setNeedsLayout(for task: TodoTask) {
        if let identifier = task.identifier {
            let layout = layouts[identifier]
            layout?.setNeedsLayout()
        }
    }
    
    func removeLayout(for task: TodoTask) {
        removeLayout(for: [task])
    }
    
    func removeLayout(for tasks: [TodoTask]) {
        for task in tasks {
            if let identifier = task.identifier {
                layouts.removeValue(forKey: identifier)
            }
        }
    }
    
    func removeAllLayouts() {
        layouts.removeAll()
    }
}

class TodoTaskInfoLayout {
    
    /// 显示详情
    var showDetail: Bool = true {
        didSet {
            if showDetail != oldValue {
                setNeedsLayout()
            }
        }
    }

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
    var config: TodoTaskLayoutConfig = TodoTaskLayoutConfig() {
        didSet {
            if config != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 详细显示选项
    var detailOption: TodoTaskDetailOption {
        get {
            return detailProvider.option
        }
        
        set {
            if detailProvider.option != newValue {
                detailProvider.option = newValue
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
    
    /// 进度条是否隐藏
    var isProgressHidden: Bool {
        return !(config.canShowProgress && task.isProgressSet)
    }
    
    /// 详情信息供应器
    private(set) var detailProvider: TodoTaskDetailProvider
    
    /// 任务
    let task: TodoTask
    
    /// 是否需要布局
    private var _shouldLayout: Bool = true
    
    private var modificateDate: Date?
    
    init(task: TodoTask) {
        self.task = task
        self.detailProvider = TodoTaskDetailProvider(task: task)
    }
    
    func setNeedsLayout() {
        _shouldLayout = true
    }
    
    private var shouldLayout: Bool {
        return _shouldLayout || modificateDate != task.modificationDate
    }
    
    func layoutIfNeeded() {
        guard shouldLayout else {
            return
        }
        
        layout()
    }
    
    /// 计算布局
    func layout() {
        let labelWidth = width - config.padding.horizontalLength - config.checkboxMargins.horizontalLength - config.checkboxConfig.size.width
        guard labelWidth > 0 else {
            return
        }
        
        /// 计算名称高度
        let nameSize: CGSize = .boundingSize(string: task.name,
                                             font: config.nameFont,
                                             constraintWidth: labelWidth,
                                             linesCount: config.nameLinesCount)
        self.nameHeight = nameSize.height
        
        /// 计算详情高度
        if showDetail {
            let attributedDetail = detailProvider.attributedInfo()
            let detailSize: CGSize = .boundingSize(string: attributedDetail,
                                                   font: config.detailFont,
                                                   constraintWidth: labelWidth,
                                                   linesCount: config.detailLinesCount)
            detailHeight = detailSize.height
        } else {
            detailHeight = 0.0
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
        /// 更新当前更新日期
        modificateDate = task.modificationDate
    }
}
