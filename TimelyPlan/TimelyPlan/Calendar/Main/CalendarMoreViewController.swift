//
//  CalendarMoreViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/11.
//

import Foundation
import EventKit
import UIKit

class CalendarMoreViewController: TPTableSectionsViewController {
    
    /// 返回
    lazy var dismissButtonItem: UIBarButtonItem = {
        let image = resGetImage("chevron_right_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickDismiss))
        return item
    }()
    
    /// 设置
    lazy var settingBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("todo_home_setting_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickSetting))
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = dismissButtonItem
        navigationItem.rightBarButtonItem = settingBarButtonItem
        wrapperView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.01))
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        
        CalendarSystemManager.shared.requestAccess { granted in
            guard granted else {
                return
            }

            CalendarSystemManager.shared.fetchSortedGroupedCalendars { result in
                self.reloadData(with: result)
            }
        }
        
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func reloadData(with result: [(EKSource, [EKCalendar])]) {
        var sourceSectionControllers = [CalendarSourceSectionController]()
        for (source, calendars) in result {
            let sectionController = CalendarSourceSectionController(source: source,
                                                                    calendars: calendars)
            sourceSectionControllers.append(sectionController)
        }
        
        sectionControllers = sourceSectionControllers
        reloadData()
    }
    
    // MARK: - Event Response
    @objc private func clickDismiss() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true)
    }
    
    @objc private func clickSetting() {
        TPImpactFeedback.impactWithSoftStyle()
        CalendarPresenter.showSetting()
    }
}


class CalendarSourceSectionController: TPTableBaseSectionController {
    
    let source: EKSource
    
    let calendars: [EKCalendar]
    
    init(source: EKSource, calendars: [EKCalendar]) {
        self.source = source
        self.calendars = calendars
        super.init()
        self.identifier = source.sourceIdentifier
    }
    
    override var items: [ListDiffable]? {
        return calendars
    }
    
    override func heightForHeader() -> CGFloat {
        return 55.0
    }
    
    override func classForHeader() -> AnyClass? {
        return TPDefaultInfoTableHeaderFooterView.self
    }
    
    override func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        guard let headerView = headerView as? TPDefaultInfoTableHeaderFooterView else {
            return
        }
        
        headerView.contentPadding = UIEdgeInsets(top: 15.0, left: 16.0, bottom: 0.0, right: 16.0)
        headerView.title = resGetString(source.title)
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 50.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return CalendarSourceCalendarCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? CalendarSourceCalendarCell else {
            return
        }
        
        cell.calendar = item(at: index) as? EKCalendar
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        return true
    }
}


class CalendarSourceCalendarCell: TPDefaultInfoTableCell {
    
    var calendar: EKCalendar? {
        didSet {
            updateCalendarInfo()
        }
    }
    
    /// 选中按钮
    private let checkboxSize = CGSize(width: 20.0, height: 20.0)
    private let checkboxMargins = UIEdgeInsets(right: 10.0)
    private(set) lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.padding = .zero
        checkbox.innerColor = resGetColor(.title)
        checkbox.outerColor = checkbox.innerColor
        return checkbox
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        leftView = checkbox
        leftViewSize = checkboxSize
        leftViewMargins = checkboxMargins
        titleConfig.font = BOLD_SYSTEM_FONT
        titleConfig.textColor = resGetColor(.title)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
    }
    
    private func updateCalendarInfo() {
        guard let calendar = calendar else {
            return
        }

        let color = UIColor(cgColor: calendar.cgColor)
        checkbox.outerColor = color
        checkbox.innerColor = color
        title = calendar.title
    }
}
