//
//  WSMyDayHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 组件头部

/// 我的一天组件通用的头部：左侧为模块标题，右侧为日期。
///
/// 尺寸由外部决定，高度取 `preferredHeight`，宽度铺满可用区域。
class WSMyDayHeaderView: UIView {
    
    /// 建议高度
    static let preferredHeight: CGFloat = 18.0
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 标题与日期字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 13.0)
        static let dateFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /// 标题与日期之间的间距
        static let spacing: CGFloat = 8.0
    }
    
    /// 展示的日期。传 nil 时清空日期
    var date: Date? {
        didSet {
            dateLabel.text = date?.yearMonthDayWeekdaySymbolString(style: .short,
                                                                   omitYear: true,
                                                                   showRelativeDate: true)
            setNeedsLayout()
        }
    }
    
    /// 标题
    private lazy var titleView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.padding = .zero
        view.accessoryPosition = .left
        view.imageName = "myDay_24"
        view.imageConfig.size = .size(4)
        view.imageConfig.margins = UIEdgeInsets(right: 4.0)
        view.imageConfig.color = .greenPrimary
        view.imageConfig.shouldRenderImageWithColor = true
        view.titleConfig.font = Metrics.titleFont
        view.titleConfig.textAlignment = .left
        view.titleConfig.textColor = .greenPrimary
        view.title = resGetString("My Day")
        return view
    }()
    
    /// 日期标签
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.dateFont
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleView)
        addSubview(dateLabel)
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
        
        /// 标题靠左，日期靠右，两者在头部行内居中
        let titleSize = titleView.sizeThatFits(contentFrame.size)
        titleView.size = CGSize(width: min(titleSize.width, contentFrame.width), height: contentFrame.height)
        titleView.left = contentFrame.minX
        titleView.top = contentFrame.minY
        
        let dateLeft = titleView.right + Metrics.spacing
        dateLabel.size = CGSize(width: max(contentFrame.maxX - dateLeft, 0.0),
                                height: ceil(Metrics.dateFont.lineHeight))
        dateLabel.right = contentFrame.maxX
        dateLabel.centerY = titleView.centerY
    }
}
