//
//  StatsContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/9.
//

import Foundation
import UIKit

class StatsContentViewController: TPCollectionSectionsViewController,
                                    TPPreviousNextDateViewDelegate {

    /// 周开始日
    private(set) var firstWeekday: Weekday = .firstWeekday

    /// 统计类型
    private(set) var type: StatsType = .week

    /// 当前选中日期
    private(set) var date: Date
    
    /// 当前日期范围
    private(set) var dateRange: DateRange
    
    /// 前后日期视图
    var dateViewHeight = 60.0
    private(set) var dateView: TPPreviousNextDateView
    
    init(type: StatsType, date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        self.type = type
        self.date = date
        self.firstWeekday = firstWeekday
        switch type {
        case .day:
            self.dateView = TPPreviousNextDayView()
        case .week:
            self.dateView = TPPreviousNextWeekView(firstWeekday: firstWeekday)
        case .month:
            self.dateView = TPPreviousNextMonthView()
        case .year:
            self.dateView = TPPreviousNextYearView()
        }
        
        self.dateView.date = date
        self.dateRange = self.dateView.dateRange
        super.init(nibName: nil, bundle: nil)
        self.dateView.delegate = self
        self.dateView.addSeparator(position: .bottom) /// 添加分割线
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 内容间距
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            updateCollectionConfiguration()
        }
    }
    
    lazy var cellStyle: TPCollectionCellStyle = {
        let cellColor = resGetColor(.title)
        let style = TPCollectionCellStyle()
        style.cornerRadius = 16.0
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .tertiarySystemBackground
        return style
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.dateView)
        self.updateCollectionConfiguration()
        self.adapter.cellStyle = self.cellStyle
        self.reloadData()
    }

    override func reloadData() {
        reloadData(completion: nil)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func reloadData(completion: (() -> Void)?) {
        let date = self.date
        self.fetchSectionControllers { [weak self] sectionControllers in
            guard let self = self, date == self.date else {
                return
            }
            
            self.sectionControllers = sectionControllers
            self.adapter.reloadData()
            completion?()
        }
    }
    
    override func viewWillLayoutSubviews() {
         super.viewWillLayoutSubviews()
         dateView.width = view.width
         dateView.height = dateViewHeight
    }

    override func collectionViewFrame() -> CGRect {
        return CGRect(x: 0,
                      y: dateViewHeight,
                      width: view.width,
                      height: view.height - dateViewHeight)
    }

    func placeholderView() -> UIView? {
        return nil
    }
    
    /// 更新列表配置
    func updateCollectionConfiguration() {
        self.wrapperView.collectionConfiguration = { [weak self] collectionView in
            collectionView.showsVerticalScrollIndicator = false
            collectionView.placeholderView = self?.placeholderView()
            collectionView.contentInset = self?.contentInset ?? .zero
        }
    }
    
    // MARK: - TPPreviousNextDateViewDelegate
    func prviousNextDateView(_ view: TPPreviousNextDateView, didSelectDate date: Date) {
        let oldDate = self.date
        self.date = date
        guard view.dateRange != self.dateRange else {
            /// 范围相同不更新数据
            return
        }
        
        self.dateRange = view.dateRange
        let animateStyle: SlideStyle = .horizontalStyle(fromValue: oldDate, toValue: date)
        self.fetchSectionControllers { [weak self] sectionControllers in
            guard let self = self, date == self.date else {
                return
            }
            
            self.sectionControllers = sectionControllers
            self.wrapperView.reloadData(animateStyle: animateStyle)
        }
    }
    
    // MARK: - 子类重写
    func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        
    }
    
    // MARK: - helpers
    static func dateRange(of type: StatsType, date: Date, firstWeekday: Weekday)-> DateRange {
        switch type {
        case .day:
            return date.rangeOfThisDay()
        case .week:
            return date.rangeOfThisWeek(firstWeekday: firstWeekday)
        case .month:
            return date.rangeOfThisMonth()
        case .year:
            return date.rangeOfThisYear()
        }
    }
    
}

