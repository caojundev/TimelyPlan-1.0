//
//  MyDayCountdownEventBindCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/25.
//

import Foundation
import UIKit

class MyDayCountdownEventBindCell: TPBaseTableCell, SearchHighlightable {
    
    /// 倒数日事项
    var event: CountdownEvent? {
        didSet {
            updateInfo()
        }
    }
    
    /// 选中按钮
    private let checkboxSize = CGSize(width: 20.0, height: 20.0)
    private let checkboxMargins = UIEdgeInsets(right: 15.0)
    private(set) lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.padding = .zero
        checkbox.innerColor = resGetColor(.title)
        checkbox.outerColor = checkbox.innerColor
        return checkbox
    }()
    
    /// 信息视图（表情图标 + 名称 + 详情）
    private let infoView = CountdownEventListInfoView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = checkbox
        rightViewSize = checkboxSize
        rightViewMargins = checkboxMargins
        contentView.padding = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 8.0)
        contentView.addSubview(infoView)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = availableLayoutFrame()
    }
    
    /// 更新信息
    func updateInfo() {
        guard let event = event else {
            return
        }
        
        infoView.icon = TPIcon(text: event.emoji ?? event.type.emoji)
        infoView.iconBackColor = event.color ?? event.type.color
        
        /// 标题（支持搜索高亮）
        if let eventName = event.name,
           let highlightedText = highlightedText,
           highlightedText.count > 0 {
            let value = eventName.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
            infoView.title = ASAttributedString(value: value)
        } else {
            infoView.title = event.displayName
        }
        
        let detailProvider = CountdownEventDetailProvider(event: event)
        infoView.subtitle = detailProvider.attributedInfo()
        setNeedsLayout()
    }
    
    // MARK: - SearchHighlightable
    /// 高亮文本
    var highlightedText: String?
    
    /// 获取默认的正常文本属性
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.label,
            .font: infoView.titleConfig.font
        ]
    }
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: infoView.titleConfig.font
        ]
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfo()
    }
}

// MARK: - 绑定操作

/// 我的一天倒数日绑定操作
///
/// 绑定列表与搜索结果共用同一套选中逻辑：
/// - 事项已加入「我的一天」：点击直接切换为不显示
/// - 事项未加入：弹出显示方式菜单选择（参考 `CountdownDisplayEditSectionController`）
enum MyDayCountdownBindHandler {
    
    /// 是否已加入「我的一天」
    static func isAddedToMyDay(_ event: CountdownEvent) -> Bool {
        return event.myDayDisplayMode != .none
    }
    
    /// 处理选中
    /// - Parameters:
    ///   - event: 选中的倒数日事项
    ///   - sourceView: 菜单锚点视图（未加入「我的一天」时用于弹出显示方式菜单）
    static func handleSelection(of event: CountdownEvent,
                                from sourceView: UIView?) {
        /// 已加入「我的一天」时直接切换为不显示
        if isAddedToMyDay(event) {
            update(event, myDayDisplayMode: .none)
            return
        }
        
        guard let sourceView = sourceView else {
            return
        }
        
        /// 未加入时由用户选择显示方式
        let menu = CountdownDisplayModeMenuController(currentDisplayMode: event.myDayDisplayMode)
        menu.didSelectDisplayMode = { mode in
            update(event, myDayDisplayMode: mode)
        }
        
        menu.show(from: sourceView)
    }
    
    /// 更新「我的一天」显示方式
    private static func update(_ event: CountdownEvent,
                               myDayDisplayMode mode: CountdownDisplayMode) {
        CountdownRepository.updateEvent(event, myDayDisplayMode: mode)
    }
}
