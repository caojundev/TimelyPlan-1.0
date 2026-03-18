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
    
    private let backViewSize: CGSize = .size(10)
    
    var backViewMargins = UIEdgeInsets(value: 15.0)
    
    /// 返回按钮
    private(set) var backView: TPFlipBackTodayView?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.dateView)
        self.updateCollectionConfiguration()
        self.adapter.cellStyle = self.cellStyle
        self.reloadData()
        self.updateBackView()
        self.setupBackView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        dateView.width = view.width
        dateView.height = dateViewHeight
        
        if let backView = backView {
            let backLayoutFrame = view.safeLayoutFrame().inset(by: backViewMargins)
            backView.size = backViewSize
            backView.bottom = backLayoutFrame.maxY
            backView.right = backLayoutFrame.maxX
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func setupBackView() {
        guard self.backView == nil else {
            return
        }
        
        let backView = TPFlipBackTodayView()
        backView.showTodayButton()
        backView.didClickBack = { [weak self] button in
            self?.didClickBack(button)
        }
        
        self.view.addSubview(backView)
        self.backView = backView
    }
    
    override func reloadData() {
        reloadData(completion: nil)
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
        
        updateBackView()
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
    
    private func updateBackView() {
        guard let backView = backView else {
            return
        }

        if self.dateRange.contains(date: .now) {
            backView.showTodayButton()
        }else{
            if self.date < .now {
                backView.showLeftBackButton()
            } else {
                backView.showRightBackButton()
            }
        }
    }
    
    @objc private func didClickBack(_ button: UIButton) {
        let date = Date()
        self.selectDate(date, from: self.date)
        self.dateView.setDate(date, animated: true)
        self.updateBackView()
    }
    
    // MARK: - TPPreviousNextDateViewDelegate
    func prviousNextDateView(_ view: TPPreviousNextDateView, didSelectDate date: Date) {
        self.selectDate(date, from: self.date)
        self.updateBackView()
    }
    
    // MARK: - 子类重写
    func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        
    }
    
    private func selectDate(_ date: Date, from oldDate: Date) {
        self.date = date
        let newDateRange = Self.dateRange(of: self.type,
                                          date: date,
                                          firstWeekday: self.firstWeekday)
        guard newDateRange != self.dateRange else {
            /// 范围相同不更新数据
            return
        }
        
        self.dateRange = newDateRange
        let animateStyle: SlideStyle = .horizontalStyle(fromValue: oldDate, toValue: date)
        self.fetchSectionControllers { [weak self] sectionControllers in
            guard let self = self, date == self.date else {
                return
            }
            
            self.sectionControllers = sectionControllers
            self.wrapperView.reloadData(animateStyle: animateStyle)
        }
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

