//
//  WSFocusSmallMonthHeatMapContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·小·本月热力图的内容视图。
///
/// 自上而下依次展示月份、专注时长、当月热力图。
class WSFocusSmallMonthHeatMapContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 16.0)
        
        /// 信息区与热力图的间距
        static let heatMapSpacing: CGFloat = 4.0
        
        /// 月份字体
        static let dateFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /// 时长字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 20.0)
        
        /// 时长单位字体
        static let titleUnitFont = UIFont.boldSystemFont(ofSize: 10.0)
    }
    
    /// 月份标签
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.dateFont
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = .secondaryLabel
        return label
    }()
    
    /// 时长
    private let infoView = TPInfoView()
    
    /// 本月热力图
    private let heatMapView = WSFocusMonthHeatMapView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        infoView.titleConfig = .withFont(Metrics.titleFont,
                                         textColor: .label,
                                         adjustsFontSizeToFitWidth: true,
                                         minimumScaleFactor: 0.5)
        
        addSubview(dateLabel)
        addSubview(infoView)
        addSubview(heatMapView)
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
        
        dateLabel.size = CGSize(width: contentFrame.width, height: ceil(Metrics.dateFont.lineHeight))
        dateLabel.origin = contentFrame.origin
        
        /// 时长按文案行高固定高度，剩余空间全部留给热力图
        let infoHeight = ceil(Metrics.titleFont.lineHeight)
        infoView.size = CGSize(width: contentFrame.width, height: infoHeight)
        infoView.left = contentFrame.minX
        infoView.top = dateLabel.bottom
        
        heatMapView.size = CGSize(width: contentFrame.width,
                                  height: max(contentFrame.maxY - infoView.bottom - Metrics.heatMapSpacing, 0.0))
        heatMapView.left = contentFrame.minX
        heatMapView.top = infoView.bottom + Metrics.heatMapSpacing
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSFocusMonthHeatMapDataItem else {
            dateLabel.text = nil
            infoView.title = nil
            heatMapView.days = []
            heatMapView.dayLevels = [:]
            setNeedsLayout()
            return
        }
        
        dateLabel.text = dataItem.date.yearMonthString
        infoView.title = dataItem.duration.attributedTitle(symbolFont: Metrics.titleUnitFont)
        
        heatMapView.days = dataItem.date.calendarMonthDays(firstWeekday: Weekday.firstWeekday)
        heatMapView.month = dataItem.date.month
        heatMapView.dayLevels = dataItem.dayLevels
        
        setNeedsLayout()
    }
}
