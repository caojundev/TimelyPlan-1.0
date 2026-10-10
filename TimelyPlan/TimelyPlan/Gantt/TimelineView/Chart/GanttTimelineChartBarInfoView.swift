//
//  GanttTimelineChartBarInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/27.
//

import Foundation
import UIKit

// MARK: - GanttEvent 扩展
extension GanttEvent {
    
    /// 事项来源图标
    var icon: TPIcon? {
        switch source {
        case .goal:
            return TPIcon(name: "goal_24")
        case .todo:
            let isCompleted = (sourceItem as? TodoTask)?.isCompleted ?? false
            return TPIcon(name: isCompleted ? "todo_circle_completed_24" : "todo_circle_normal_24")
        }
    }
    
    /// 事项是否已完成
    var isCompleted: Bool {
        switch source {
        case .goal:
            return (sourceItem as? GoalTask)?.isCompleted ?? false
        case .todo:
            return (sourceItem as? TodoTask)?.isCompleted ?? false
        }
    }
}

// MARK: - 甘特图 bar 信息视图
/// 甘特图 bar 的信息视图：左侧为事件来源图标，右侧为标题
class GanttTimelineChartBarInfoView: UIView {
    
    // MARK: - 配置
    
    /// 图标尺寸
    var iconSize: CGSize = .size(6) {
        didSet {
            guard iconSize != oldValue else { return }
            iconView.size = iconSize
            setNeedsLayout()
        }
    }
    
    /// 图标圆角
    var iconCornerRadius: CGFloat = .greatestFiniteMagnitude {
        didSet {
            guard iconCornerRadius != oldValue else { return }
            iconView.cornerRadius = iconCornerRadius
        }
    }
    
    /// 图标与标题之间的间距
    var spacing: CGFloat = 4.0 {
        didSet {
            guard spacing != oldValue else { return }
            setNeedsLayout()
        }
    }
    
    /// 标题对齐方式
    var titleAlignment: NSTextAlignment = .left {
        didSet {
            guard titleAlignment != oldValue else { return }
            titleLabel.textAlignment = titleAlignment
            setNeedsLayout()
        }
    }
    
    /// 标题换行模式
    var titleLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            guard titleLineBreakMode != oldValue else { return }
            titleLabel.lineBreakMode = titleLineBreakMode
        }
    }
    
    /// 标题内容（显示内容与原来保持一致）
    var title: String? {
        get {
            return titleLabel.text
        }
        
        set {
             titleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    /// 标题颜色
    var titleColor: UIColor? {
        get {
            return titleLabel.normalTextColor
        }
        
        set {
            guard let titleColor = newValue else { return }
            titleLabel.normalTextColor = titleColor
            titleLabel.strikethroughTextColor = titleColor.withAlphaComponent(0.5)
            titleLabel.strikethroughColor = titleColor.withAlphaComponent(0.6)
        }
    }
    
    /// 标题是否显示删除线（事项已完成）
    var isStrikethrough: Bool {
        get {
            return titleLabel.isStrikethrough
        }
        
        set {
            guard titleLabel.isStrikethrough != newValue else { return }
            titleLabel.isStrikethrough = newValue
            titleLabel.setNeedsLayout()
        }
    }
    
    // MARK: - 子视图
    
    /// 图标视图
    private(set) lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.borderWidth = 0.0
        view.cornerRadius = iconCornerRadius
        view.size = iconSize
        return view
    }()
    
    /// 标题标签
    private(set) lazy var titleLabel: TPStrikethroughLabel = {
        let label = TPStrikethroughLabel()
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 12.0)
        label.textAlignment = titleAlignment
        label.lineBreakMode = titleLineBreakMode
        label.isUserInteractionEnabled = false
        return label
    }()
    
    // MARK: - 内容尺寸
    
    /// 图标是否可见（无图标时不占位）
    private var isIconVisible: Bool {
        return !iconView.isEmpty
    }
    
    /// 图标占用的宽度（含与标题的间距）
    private var iconOccupiedWidth: CGFloat {
        guard isIconVisible else { return 0 }
        return iconSize.width + spacing
    }
    
    /// 标题完整显示所需宽度
    private var titleContentWidth: CGFloat {
        return titleLabel.sizeThatFits(.unlimited).width
    }
    
    /// 内容（图标 + 标题）完整显示所需宽度
    var contentWidth: CGFloat {
        return iconOccupiedWidth + titleContentWidth + padding.horizontalLength
    }
    
    /// 在给定宽度限制下内容所需宽度（至少保证图标完整可见）
    func contentWidth(limitedTo maxWidth: CGFloat) -> CGFloat {
        let limitedWidth = min(contentWidth, max(0, maxWidth))
        return max(limitedWidth, iconOccupiedWidth)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 8.0)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update
    /// 根据事件更新图标与标题（图标背景为事件颜色，前景为白色）
    func update(with event: GanttEvent) {
        iconView.icon = event.icon
        iconView.backColor = event.color
        iconView.foreColor = .white
        title = event.title
        isStrikethrough = event.isCompleted
    }
    
    // MARK: - Layout
    private func setupSubviews() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        clipsToBounds = false
        
        addSubview(iconView)
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        let iconVisible = isIconVisible
        let iconWidth = iconOccupiedWidth
        
        iconView.isHidden = !iconVisible
        iconView.size = iconSize
        iconView.left = layoutFrame.minX
        iconView.centerY = layoutFrame.midY
        
        titleLabel.frame = CGRect(x: layoutFrame.minX + iconWidth,
                                  y: layoutFrame.minY,
                                  width: max(layoutFrame.width - iconWidth, 0.0),
                                  height: layoutFrame.height)
    }
}
