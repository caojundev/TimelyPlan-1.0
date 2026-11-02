//
//  WSMyDayAllDayEventsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容视图基类

/// 我的一天·全天事项的内容视图基类，各尺寸共用。
///
/// 顶部左侧为我的一天标题，右侧为当天日期；其下为全天事项行与更多入口。
/// 行数按列表可用高度换算，事项超出时最后一行让给「更多」入口；
/// 行视图类型与行高由子类通过 `makeRowView()`、`rowMinimumHeight` 等指定。
class WSMyDayAllDayEventsContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 标题与日期字体
        static let titleFont = UIFont.boldSystemFont(ofSize: 13.0)
        static let dateFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /// 标题与日期之间的间距
        static let headerSpacing: CGFloat = 8.0
        
        /// 头部与列表的间距
        static let headerListSpacing: CGFloat = 8.0
        
        /// 更多入口字体
        static let moreFont = UIFont.boldSystemFont(ofSize: 11.0)
    }
    
    // MARK: - 子类配置
    /// 行的最小高度
    var rowMinimumHeight: CGFloat = 20.0
    
    /// 行的最大高度
    var rowMaximumHeight: CGFloat = 28.0
    
    /// 行间距
    var rowSpacing: CGFloat = 2.0
    
    /// 更多入口的左缩进，与行内名称对齐
    var moreLeadingInset: CGFloat = 18.0
    
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
    
    /// 更多入口
    private lazy var moreLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.moreFont
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.isHidden = true
        return label
    }()
    
    /// 事项行，按可用高度动态创建
    private var rowViews: [WSMyDayAllDayEventRowBaseView] = []
    
    /// 当前展示的全天事项
    private var items: [WSMyDayAllDayEventItem] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleView)
        addSubview(dateLabel)
        addSubview(moreLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 子类实现
    /// 创建事项行，子类必须重写
    func makeRowView() -> WSMyDayAllDayEventRowBaseView {
        fatalError("Subclass must override makeRowView()")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        /// 标题靠左，日期靠右，两者在顶部一行内居中
        let headerHeight = max(ceil(Metrics.titleFont.lineHeight), ceil(Metrics.dateFont.lineHeight))
        let titleSize = titleView.sizeThatFits(CGSize(width: contentFrame.width, height: headerHeight))
        titleView.size = CGSize(width: min(titleSize.width, contentFrame.width), height: headerHeight)
        titleView.left = contentFrame.minX
        titleView.top = contentFrame.minY
        
        let dateLeft = titleView.right + Metrics.headerSpacing
        dateLabel.size = CGSize(width: max(contentFrame.maxX - dateLeft, 0.0),
                                height: ceil(Metrics.dateFont.lineHeight))
        dateLabel.right = contentFrame.maxX
        dateLabel.centerY = titleView.centerY
        
        let listTop = titleView.bottom + Metrics.headerListSpacing
        let listHeight = max(contentFrame.maxY - listTop, 0.0)
        let (visibleCount, hiddenCount) = displayedCounts(listHeight: listHeight)
        let rowHeight = slotHeight(slotCount: visibleCount + (hiddenCount > 0 ? 1 : 0),
                                   listHeight: listHeight)
        let rowStep = rowHeight + rowSpacing
        
        for index in 0..<visibleCount {
            let rowView = rowView(at: index)
            rowView.isHidden = false
            rowView.update(with: items[safe: index])
            rowView.frame = CGRect(x: contentFrame.minX,
                                   y: listTop + CGFloat(index) * rowStep,
                                   width: contentFrame.width,
                                   height: rowHeight)
        }
        
        for index in visibleCount..<rowViews.count {
            rowViews[index].isHidden = true
        }
        
        layoutMoreLabel(hiddenCount: hiddenCount,
                        frame: CGRect(x: contentFrame.minX + moreLeadingInset,
                                      y: listTop + CGFloat(visibleCount) * rowStep,
                                      width: max(contentFrame.width - moreLeadingInset, 0.0),
                                      height: rowHeight))
    }
    
    /// 按需创建事项行
    private func rowView(at index: Int) -> WSMyDayAllDayEventRowBaseView {
        while rowViews.count <= index {
            let rowView = makeRowView()
            rowView.didSelectEventHandler = { [weak self] dataItem in
                self?.interactor?.performAction(with: dataItem)
            }
            
            rowViews.append(rowView)
            insertSubview(rowView, belowSubview: moreLabel)
        }
        
        return rowViews[index]
    }
    
    /// 需要展示的事项数与未展示的事项数。事项超出可用行数时，最后一行留给更多入口
    private func displayedCounts(listHeight: CGFloat) -> (visible: Int, hidden: Int) {
        let totalCount = items.count
        guard totalCount > 0, listHeight > 0.0 else {
            return (0, 0)
        }
        
        let slotCount = max(Int((listHeight + rowSpacing) / (rowMinimumHeight + rowSpacing)), 1)
        guard totalCount > slotCount else {
            return (totalCount, 0)
        }
        
        let visibleCount = max(slotCount - 1, 0)
        return (visibleCount, totalCount - visibleCount)
    }
    
    /// 单个槽位的高度。行高过大时封顶，避免事项较少时行被拉得过开
    private func slotHeight(slotCount: Int, listHeight: CGFloat) -> CGFloat {
        guard slotCount > 0, listHeight > 0.0 else {
            return 0.0
        }
        
        let height = (listHeight - CGFloat(slotCount - 1) * rowSpacing) / CGFloat(slotCount)
        return min(max(height, 0.0), rowMaximumHeight)
    }
    
    /// 更新更多入口的文案与显隐
    private func layoutMoreLabel(hiddenCount: Int, frame: CGRect) {
        moreLabel.isHidden = hiddenCount <= 0
        guard hiddenCount > 0 else {
            return
        }
        
        moreLabel.text = String(format: resGetString("More %ld"), hiddenCount)
        moreLabel.frame = frame
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSMyDayAllDayEventsDataItem else {
            dateLabel.text = nil
            items = []
            setNeedsLayout()
            return
        }
        
        dateLabel.text = dataItem.date.yearMonthDayWeekdaySymbolString(style: .short,
                                                                      omitYear: true,
                                                                      showRelativeDate: true)
        items = dataItem.items
        
        setNeedsLayout()
    }
}
