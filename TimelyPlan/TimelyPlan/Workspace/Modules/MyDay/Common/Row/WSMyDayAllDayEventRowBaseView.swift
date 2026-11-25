//
//  WSMyDayAllDayEventRowBaseView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 行视图基类

/// 全天事项行视图基类，各尺寸共用。
///
/// 收拢行的共有部分：名称、完成态配色、按下高亮与点击回调；
/// 左侧配件（颜色圆点或类型图标）的布局与刷新由子类实现。
class WSMyDayAllDayEventRowBaseView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 6.0
        
        /// 按下时行底色的透明度
        static let highlightedBackgroundColorAlpha: CGFloat = 0.1
    }
    
    /// 事项名称
    let titleLabel = UILabel()
    
    /// 当前展示的事项
    private(set) var dataItem: WSMyDayAllDayEventItem?
    
    /// 点击行回调
    var didSelectEventHandler: ((WSMyDayAllDayEventItem) -> Void)?
    
    /// 左侧配件与名称的间距
    var accessoryTitleSpacing: CGFloat {
        return 8.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentCornerRadius = Metrics.cornerRadius
        
        titleLabel.font = .systemFont(ofSize: 13.0, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)
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
        
        let titleLeft = layoutAccessory(in: contentFrame) + accessoryTitleSpacing
        titleLabel.frame = CGRect(x: titleLeft,
                                  y: contentFrame.minY,
                                  width: max(contentFrame.maxX - titleLeft, 0.0),
                                  height: contentFrame.height)
    }
    
    /// 布局左侧配件，返回配件的右边界。子类重写
    func layoutAccessory(in contentFrame: CGRect) -> CGFloat {
        return contentFrame.minX
    }
    
    // MARK: - 渲染
    /// 更新展示的事项。传 nil 时清空内容
    func update(with dataItem: WSMyDayAllDayEventItem?) {
        /// 内容视图每次布局都会调用，同一条目直接跳过，避免反复解析图标与设置文案
        if self.dataItem?.event === dataItem?.event,
           self.dataItem?.isCompleted == dataItem?.isCompleted,
           titleLabel.text == dataItem?.title {
            return
        }
        
        self.dataItem = dataItem
        
        titleLabel.text = dataItem?.title
        /// 已完成的事项弱化名称，与时间线中已完成任务的观感一致
        titleLabel.textColor = (dataItem?.isCompleted ?? false) ? .secondaryLabel : .label
        reloadAccessory()
        
        normalBackColor = .clear
        highlightedBackColor = dataItem == nil ? .clear : Color(0x888888, Metrics.highlightedBackgroundColorAlpha)
        
        setNeedsLayout()
    }
    
    /// 刷新左侧配件。子类重写
    func reloadAccessory() {
        
    }
    
    // MARK: - 交互
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectEventHandler?(dataItem)
    }
}
