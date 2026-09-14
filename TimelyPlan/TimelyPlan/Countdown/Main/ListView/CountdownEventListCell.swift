//
//  CountdownEventListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

protocol CountdownEventListCellDelegate: AnyObject {
    /// 点击更多
    func countdownEventListCellDidClickMore(_ cell: CountdownEventListCell)
}

class CountdownEventCellStyle: TPCollectionCellStyle {
    
    override init() {
        super.init()
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .tertiarySystemGroupedBackground
        self.cornerRadius = 12.0
    }
}

class CountdownEventListCell: TPCollectionCell {
    
    /// 单元格默认高度
    static let cellHeight = 100.0
    
    /// 倒数日事项
    var event: CountdownEvent? {
        didSet {
            self.updateInfo()
        }
    }
    
    /// 信息视图
    let infoView = CountdownEventListInfoView()
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        
        contentView.padding = UIEdgeInsets(top: 15.0,
                                           left: 16.0,
                                           bottom: 15.0,
                                           right: 12.0)
        infoView.rightAccessoryView = moreButton
        infoView.rightAccessorySize = .mini
        infoView.rightAccessoryMargins = UIEdgeInsets(left: 4.0)
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = contentView.layoutFrame()
    }
    
    /// 更新信息
    func updateInfo() {
        guard let event = event else {
            return
        }
        
        infoView.icon = TPIcon(text: event.emoji ?? event.type.emoji)
        infoView.title = event.displayName
        
        /// 副标题：由 CountdownEventDetailProvider 统一计算（目标日期 + 剩余天数）
        infoView.subtitle = CountdownEventDetailProvider.detail(for: event)
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? CountdownEventListCellDelegate {
            delegate.countdownEventListCellDidClickMore(self)
        }
    }
}

/// 倒数日事项信息视图（左配件为表情图标）
class CountdownEventListInfoView: TPInfoView {
    
    /// 图标尺寸
    let iconSize = CGSize(width: 44.0, height: 44.0)
    
    /// 图标
    var icon: TPIcon? {
        get {
            return iconView.icon
        }
        
        set {
            iconView.icon = newValue
        }
    }
    
    /// 图标视图
    private lazy var iconView: TPIconView = {
        let view = TPIconView()
        view.font = UIFont.systemFont(ofSize: 26.0)
        view.backColor = .secondarySystemFill
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        subtitleTopMargin = 8.0
        leftAccessoryView = iconView
        leftAccessorySize = iconSize
        leftAccessoryMargins = UIEdgeInsets(right: 12.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.cornerRadius = iconSize.height / 2.0
    }
}

class CountdownEventDetailProvider {
    
    /// 副标题组件：目标日期 + 剩余天数
    static func subtitleComponents(for event: CountdownEvent) -> [ASAttributedString] {
        var components = [ASAttributedString]()
        
        /// 目标日期（本年度省略年份）
        let dateString = event.targetDate.yearMonthDayString(omitYear: true, showRelativeDate: false)
        components.append(dateString.attributedString)
        
        /// 剩余天数
        components.append(remainingDescription(for: event).attributedString)
        
        return components
    }
    
    /// 副标题
    static func detail(for event: CountdownEvent) -> ASAttributedString {
        return subtitleComponents(for: event).joined(separator: " • ")
    }
    
    /// 剩余天数描述（正数为剩余天数，负数为已经过去的天数）
    static func remainingDescription(for event: CountdownEvent) -> String {
        let days = event.remainingDays
        if days == 0 {
            return resGetString("Today")
        }
        
        let titleKey: String
        if days == 1 {
            titleKey = "%ld day later"
        } else if days > 1 {
            titleKey = "%ld days later"
        } else if days == -1 {
            titleKey = "%ld day before"
        } else {
            titleKey = "%ld days before"
        }
        
        return String(format: resGetString(titleKey), abs(days))
    }
}
