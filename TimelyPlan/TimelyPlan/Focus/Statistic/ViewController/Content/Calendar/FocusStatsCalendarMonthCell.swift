//
//  FocusStatsCalendarMonthCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 单元格
class FocusStatsCalendarMonthCellItem: TPCollectionCellItem {
    
    /// 月视图代理对象
    weak var monthViewDelegate: TPCalendarMonthViewDelegate?
    
    /// 周开始日
    var firstWeekday: Weekday = .firstWeekday
    
    /// 周当中包含的日期
    var date: Date = Date()
    
    override var size: CGSize? {
        get {
            let daysCount = date.calendarMonthDaysCount(firstWeekday: firstWeekday)
            let weeksCount = CGFloat(daysCount / DAYS_PER_WEEK)
            var height = contentPadding.verticalLength
            height += FocusStatsCalendarMonthView.symbolsViewHeight
            height += FocusStatsCalendarMonthView.descriptionLabelHeight
            height += weeksCount * FocusStatsCalendarMonthView.dayCellHeight
            return CGSize(width: .greatestFiniteMagnitude, height: height)
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.contentPadding = UIEdgeInsets(vertical: 15.0)
        self.registerClass = FocusStatsCalendarMonthCell.self
        self.canHighlight = false
        self.scaleWhenHighlighted = false
    }
}

class FocusStatsCalendarMonthCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    let monthView = FocusStatsCalendarMonthView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(monthView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthView.frame = contentView.layoutFrame()
    }
    
    func reloadData() {
        guard let cellItem = cellItem as? FocusStatsCalendarMonthCellItem else {
            return
        }
        
        monthView.firstWeekday = cellItem.firstWeekday
        monthView.date = cellItem.date
        monthView.monthViewDelegate = cellItem.monthViewDelegate
        monthView.reloadData()
        setNeedsLayout()
    }
}

// MARK: - 月视图
class FocusStatsCalendarMonthView: UIView {
    
    /// 周符号高度
    static let symbolsViewHeight: CGFloat = 36.0
    
    /// 日单元格高度
    static let dayCellHeight: CGFloat = 64.0
    
    /// 描述标签高度
    static let descriptionLabelHeight: CGFloat = 20.0
    static let descriptionLabelMargin: CGFloat = 16.0
    
    /// 等级图标尺寸
    private static let legendIconSize = CGSize(width: 10.0, height: 10.0)
    
    /// 等级图标画布尺寸
    private static let legendIconCanvasSize = CGSize(width: 12.0, height: 12.0)
    
    weak var monthViewDelegate: TPCalendarMonthViewDelegate? {
        get {
            return monthView.delegate
        }
        
        set {
            monthView.delegate = newValue
        }
    }
    
    /// 当前月份日期
    var date: Date = Date()
    
    /// 周开始日
    var firstWeekday: Weekday = .firstWeekday
    
    /// 周符号视图
    private lazy var symbolsView: TPWeekdaySymbolView = {
        let view = TPWeekdaySymbolView(frame: .zero, style: .short)
        view.alpha = 0.8
        view.textColor = resGetColor(.title)
        return view
    }()
    
    /// 月视图
    private lazy var monthView: TPCalendarMonthView = {
        let view = TPCalendarMonthView(frame: bounds)
        return view
    }()
    
    /// 描述标签（专注时长等级说明）
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = Color(light: 0x888888, dark: 0xAFAFAF, alpha: 0.6)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(symbolsView)
        addSubview(monthView)
        addSubview(descriptionLabel)
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolsView.width = bounds.width
        symbolsView.height = Self.symbolsViewHeight
        
        /// 描述标签位于底部
        descriptionLabel.frame = CGRect(x: Self.descriptionLabelMargin,
                                        y: bounds.maxY - Self.descriptionLabelHeight,
                                        width: bounds.width - Self.descriptionLabelMargin * 2.0,
                                        height: Self.descriptionLabelHeight)
        
        monthView.width = bounds.width
        monthView.height = bounds.height - symbolsView.height - descriptionLabel.height
        monthView.top = symbolsView.bottom
    }
    
    func reloadData() {
        symbolsView.setFirstWeekday(firstWeekday)
        descriptionLabel.attributed.text = Self.legendInfo
        monthView.configure(firstWeekday: firstWeekday,
                            visibleDateComponents: date.yearMonthDayComponents)
    }
    
    // MARK: - 等级说明
    /// 专注时长等级说明富文本
    private static var legendInfo: ASAttributedString {
        var levelStrings = [ASAttributedString]()
        for level in FocusDurationLevels.allLevels() where level.level > 0 {
            guard let image = UIImage.image(color: level.color,
                                            size: legendIconSize,
                                            canvasSize: legendIconCanvasSize,
                                            cornerRadius: 2.0) else {
                continue
            }
            
            let levelString = ASAttributedString.string(image: image,
                                                        imageSize: legendIconCanvasSize,
                                                        trailingText: level.title,
                                                        separator: " ")
            levelStrings.append(levelString)
        }
        
        return levelStrings.joined(separator: "  ")
    }
}

// MARK: - 日单元格
/// 专注统计月日历日单元格（上半部分显示日期天，下半部分显示当天专注时长）
class FocusStatsCalendarMonthDayCell: TPCollectionCell {
    
    /// 日期
    var date: Date?
    
    /// 当日专注时长
    var duration: Duration = 0
    
    /// 背景内间距
    private static let backgroundInset = UIEdgeInsets(horizontal: 4.0, vertical: 4.0)
    
    /// 背景圆角半径
    private static let backgroundCornerRadius = 10.0
    
    /// 等级背景视图
    private let levelBackView = UIView()
    
    /// 日期天标签
    private lazy var dayLabel: UILabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 2.0)
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    /// 专注时长标签
    private lazy var durationLabel: UILabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 2.0)
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        scaleWhenHighlighted = false
        levelBackView.clipsToBounds = true
        contentView.addSubview(levelBackView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(durationLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.date = nil
        duration = 0 /// 重置时长，避免复用旧数据
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let layoutFrame = bounds.inset(by: Self.backgroundInset)
        /// 等级背景
        levelBackView.frame = layoutFrame
        levelBackView.layer.cornerRadius = Self.backgroundCornerRadius
    
        /// 上半部分显示日期天，下半部分显示专注时长
        dayLabel.frame = CGRect(x: layoutFrame.minX,
                                y: layoutFrame.minY,
                                width: layoutFrame.width,
                                height: layoutFrame.height / 2.0)
        durationLabel.frame = CGRect(x: layoutFrame.minX,
                                     y: dayLabel.frame.maxY,
                                     width: layoutFrame.width,
                                     height: layoutFrame.height / 3.0)
        updateAppearance()
    }
    
    /// 加载数据
    func reloadData() {
        guard let date = self.date else {
            dayLabel.text = nil
            durationLabel.text = nil
            updateAppearance()
            return
        }
        
        /// 上方显示日期天
        dayLabel.text = "\(date.day)"
        /// 下方显示专注时长
        if duration > 0 {
            durationLabel.text = duration.title
        } else {
            durationLabel.text = nil
        }
        
        updateAppearance()
    }
    
    // MARK: - 外观
    /// 更新等级背景色与文本颜色
    private func updateAppearance() {
        let level = FocusDurationLevels.levelInfo(for: duration)
        /// 按专注时长等级由浅到深填充背景色
        levelBackView.backgroundColor = level.color
        /// 深色背景标签使用白色，浅色背景标签跟随标题色
        dayLabel.textColor = level.textColor
        durationLabel.textColor = level.textColor
    }
}

