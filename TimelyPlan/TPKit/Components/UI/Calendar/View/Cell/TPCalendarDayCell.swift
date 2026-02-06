//
//  TPCalendarDayCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/12.
//

import Foundation
import UIKit

class TPCalendarDayCell: TPDefaultInfoCollectionCell {
    
    /// 选中指示圆形尺寸
    private let selectedIndicatorSize = CGSize(width: 46.0, height: 46.0)
    
    /// 天日期组件
    var dayDateComponents: DateComponents? {
        didSet {
            guard let components = dayDateComponents, let date = Date.dateFromComponents(components) else {
                return
            }
            
            var title: String?
            if date.isToday {
                title = "今"
            } else {
                title = String(date.day)
            }

            infoView.title = title
            
            var subtitle: String?
            if let holidayName = date.holidayName {
                subtitle = holidayName
            } else if let solarTermName = date.solarTermName {
                subtitle = solarTermName
            } else {
                subtitle = date.lunarCalendarDayString
            }
            
            infoView.subtitle = subtitle
            badgeView.state = TPHolidayScheduler.shared.state(for: date)
        }
    }
    
    var date: Date? {
        guard let dayDateComponents = dayDateComponents else {
            return nil
        }
        
        return Date.dateFromComponents(dayDateComponents)
    }
    
    var isToday: Bool {
        return date?.isToday ?? false
    }
    
    var isHoliday: Bool {
        return date?.isHoliday ?? false
    }
    
    var isLunarFisrtDay: Bool {
        return date?.isLunarFisrtDay ?? false
    }
    
    var isSolarTerm: Bool {
        return date?.isSolarTerm ?? false
    }
    
    lazy var badgeView: TPCalendarDayBadgeView = {
        let view = TPCalendarDayBadgeView(frame: .zero)
        return view
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(badgeView)
        cellStyle = TPCollectionCellStyle()
        scaleWhenHighlighted = false
        infoView.titleConfig.font = UIFont.boldSystemFont(ofSize: 12.0)
        infoView.titleConfig.textAlignment = .center
        infoView.subtitleConfig.font = UIFont.systemFont(ofSize: 8.0)
        infoView.subtitleConfig.alpha = 1.0
        infoView.subtitleConfig.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let backgroundFrame = backgroundView?.frame ?? bounds
        infoView.frame = backgroundFrame.middleCircleInnerSquareRect
        
        /// 布局角标
        badgeView.sizeToFit()
        badgeView.top = backgroundFrame.minY
        badgeView.right = backgroundFrame.maxX
        updateBackgroundView()
    }

    private func updateBackgroundView() {
        let cornerRadius = selectedIndicatorSize.roundCornerRadius
        backgroundView?.size = selectedIndicatorSize
        backgroundView?.alignCenter()
        backgroundView?.layer.cornerRadius = cornerRadius
        selectedBackgroundView?.size = selectedIndicatorSize
        selectedBackgroundView?.alignCenter()
        selectedBackgroundView?.layer.cornerRadius = cornerRadius
    }
    
    override func updateCellStyle() {
        guard let cellStyle = cellStyle else {
            super.updateCellStyle()
            return
        }
    
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let isPastDate = dayDateComponents?.isPastDate ?? false
        
        let highlightedBackgroundColor = isPastDate ? Color(0xFF544A) : tintColor
        var highlightedTextColor: UIColor? = highlightedBackgroundColor
        
        var backgroundColor: UIColor? = .clear
        var selectedBackgroundColor: UIColor? = highlightedBackgroundColor
        var titleColor: UIColor? = resGetColor(.title)
        var selectedTitleColor: UIColor? = .white
        
        var subtitleColor = titleColor
        var selectedSubtitleColor = selectedTitleColor
        if isHoliday || isLunarFisrtDay {
            subtitleColor = tintColor
        } else if isSolarTerm {
            subtitleColor = .orangePrimary
        } else {
            subtitleColor = .secondaryLabel
        }
        
        if isChecked {
            backgroundColor = highlightedBackgroundColor
            selectedBackgroundColor = highlightedBackgroundColor
            highlightedTextColor = selectedTitleColor
        } else if isToday {
            backgroundColor = .clear
            selectedBackgroundColor = tintColor.withAlphaComponent(0.1)
            titleColor = tintColor
            selectedTitleColor = tintColor.darkerColor
            subtitleColor = titleColor
            selectedSubtitleColor = selectedTitleColor
        } else {
            /// 高亮
            backgroundColor = .clear
            selectedBackgroundColor = highlightedBackgroundColor?.withAlphaComponent(0.1)
            selectedTitleColor = highlightedTextColor
            selectedSubtitleColor = highlightedTextColor
        }
        
        cellStyle.backgroundColor = backgroundColor
        cellStyle.selectedBackgroundColor = selectedBackgroundColor
        
        infoView.titleConfig.textColor = titleColor ?? .label
        infoView.titleConfig.highlightedTextColor = highlightedTextColor
        infoView.titleConfig.selectedTextColor = selectedTitleColor
        
        infoView.subtitleConfig.textColor = subtitleColor ?? .label
        infoView.subtitleConfig.highlightedTextColor = highlightedTextColor
        infoView.subtitleConfig.selectedTextColor = selectedSubtitleColor
        
        /// 在调用父类方法前更新 cellStyle
        super.updateCellStyle()
        
        /// 更新样式后圆角消失，重新更新背景视图
        self.updateBackgroundView()
        CATransaction.commit()
    }
}
