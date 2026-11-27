//
//  WSMyDayHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 组件头部
class WSMyDayHeaderView: TPImageInfoTextValueView {
    
    /// 建议高度
    static let preferredHeight: CGFloat = 18.0
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 标题与日期字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 13.0)
        static let dateFont = UIFont.boldSystemFont(ofSize: 12.0)
        
        /// 标题与日期之间的间距
        static let spacing: CGFloat = 8.0
    }
    
    /// 展示的日期。传 nil 时清空日期
    var date: Date? {
        didSet {
            let dateString = date?.yearMonthDayWeekdaySymbolString(style: .short,
                                                                   omitYear: true,
                                                                   showRelativeDate: false,
                                                                   slashFormatted: true)
            self.valueConfig = .valueText(dateString,
                                          font: Metrics.dateFont,
                                          textColor: .secondaryLabel)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageName = "myDay_24"
        self.imageConfig.size = .size(4)
        self.imageConfig.margins = UIEdgeInsets(right: 4.0)
        self.imageConfig.color = .greenPrimary
        self.imageConfig.shouldRenderImageWithColor = true
        self.titleConfig.font = Metrics.titleFont
        self.titleConfig.textAlignment = .left
        self.titleConfig.textColor = .greenPrimary
        self.title = resGetString("My Day")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
