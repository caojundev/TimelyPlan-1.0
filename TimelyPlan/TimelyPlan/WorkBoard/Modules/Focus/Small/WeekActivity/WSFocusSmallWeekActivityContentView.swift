//
//  WSFocusSmallWeekActivityContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·小·本周活动的内容视图。
///
/// 自上而下依次展示日期范围、专注时长与次数、一周活动视图。
class WSFocusSmallWeekActivityContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 活动视图的最大高度，含底部的星期符号
        static let maximumActivityHeight: CGFloat = 64.0
        
        /// 日期字体
        static let dateFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /// 时长字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
        
        /// 时长单位字体
        static let titleUnitFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /// 次数字体
        static let subtitleFont = UIFont.boldSystemFont(ofSize: 13.0)
    }
    
    /// 日期标签
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.dateFont
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = .secondaryLabel
        return label
    }()
    
    /// 时长与次数
    private let infoView = TPInfoView()
    
    /// 一周活动视图
    private let activityView = WSFocusWeekActivityView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        infoView.titleConfig = .withFont(Metrics.titleFont,
                                         textColor: .label,
                                         adjustsFontSizeToFitWidth: true,
                                         minimumScaleFactor: 0.5)
        infoView.subtitleConfig = .withFont(Metrics.subtitleFont, textColor: .secondaryLabel)
        infoView.subtitleTopMargin = 5.0
        
        addSubview(dateLabel)
        addSubview(infoView)
        addSubview(activityView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0 && contentFrame.height > 0.0 else {
            return
        }
        
        activityView.size = CGSize(width: contentFrame.width,
                                   height: min(Metrics.maximumActivityHeight, contentFrame.height * 0.45))
        activityView.left = contentFrame.minX
        activityView.bottom = contentFrame.maxY
        
        dateLabel.size = CGSize(width: contentFrame.width, height: ceil(Metrics.dateFont.lineHeight))
        dateLabel.origin = contentFrame.origin
        
        /// 时长与次数在日期与活动视图之间居中
        infoView.top = dateLabel.bottom
        infoView.left = contentFrame.minX
        infoView.width = contentFrame.width
        infoView.height = max(activityView.top - dateLabel.bottom, 0.0)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSFocusWeekActivityDataItem else {
            dateLabel.text = nil
            infoView.title = nil
            infoView.subtitle = nil
            activityView.dailyActivity = nil
            activityView.startDate = nil
            setNeedsLayout()
            return
        }
        
        dateLabel.text = "\(dataItem.startDate.monthDayString) - \(dataItem.endDate.monthDayString)"
        infoView.title = dataItem.duration.attributedTitle(symbolFont: Metrics.titleUnitFont)
        
        if dataItem.times > 0 {
            let timesUnit = resGetString(dataItem.times == 1 ? "Time(count)" : "Times(count)")
            infoView.subtitle = "\(dataItem.times) \(timesUnit)"
        } else {
            infoView.subtitle = "--"
        }
        
        activityView.startDate = dataItem.startDate
        activityView.dailyActivity = dataItem.dailyActivity
        
        setNeedsLayout()
    }
}
