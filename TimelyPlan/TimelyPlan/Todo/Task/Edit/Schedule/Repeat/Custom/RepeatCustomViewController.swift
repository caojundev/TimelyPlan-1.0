//
//  RepeatCustomizeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/16.
//

import Foundation
import UIKit

class RepeatCustomViewController: TPTableSectionsViewController {
    
    /// 结束编辑规则回调
    var didEndEditing: ((RecurrenceRule) -> Void)?
    
    /// 规则类型
    var ruleType: RecurrenceRuleType = .regularly
    
    /// 描述信息区块
    lazy var infoSectionController: TPTableItemSectionController = {
        let sectionItem = TPTableItemSectionController()
        sectionItem.headerItem.height = 10.0
        sectionItem.footerItem.height = 0.0
        sectionItem.cellItems = [infoCellItem]
        return sectionItem
    }()
    
    /// 描述信息单元格
    lazy var infoCellItem: TPDescriptionTableCellItem = {
        let cellItem = TPDescriptionTableCellItem()
        cellItem.updater = { [weak self] in
            self?.updateInfoCellItem()
        }
        
        cellItem.selectionStyle = .none
        cellItem.height = 45.0
        return cellItem
    }()
    
    /// 规则类型区块
    lazy var typeSectionController: TPTableItemSectionController = {
        let sectionItem = TPTableItemSectionController()
        sectionItem.headerItem.height = 10.0
        sectionItem.footerItem.height = 0.0
        sectionItem.cellItems = [typeCellItem]
        return sectionItem
    }()
    
    /// 规则类型单元格
    lazy var typeCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = RecurrenceRuleType.segmentedMenuItems()
        cellItem.updater = { [weak self] in
            self?.updateRuleTypeCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let type: RecurrenceRuleType? = menuItem.actionType()
            if let type = type {
                self?.didSelectRuleType(type)
            }
        }
        
        return cellItem
    }()

    // MARK: - 定期
    lazy var frequencySectionController: RepeatFrequencySectionController = { [weak self] in
        let sectionItem = RepeatFrequencySectionController()
        sectionItem.frequencyDidChange = { _ in
            self?.ruleEditingChanged()
        }
        
        sectionItem.intervalDidChange = { _ in
            self?.ruleEditingChanged()
        }
        
        return sectionItem
    }()
    
    lazy var daysOfWeekSectionController: RepeatDaysOfWeekSectionController = { [weak self] in
        let sectionItem = RepeatDaysOfWeekSectionController()
        sectionItem.weekdaysDidChange = { weekdays in
            self?.ruleEditingChanged()
        }
        
        return sectionItem
    }()
    
    lazy var daysOfMonthSectionController: RepeatDaysOfMonthSectionController = { [weak self] in
        let sectionItem = RepeatDaysOfMonthSectionController()
        sectionItem.daysOfTheMonthDidChange = { daysOfTheMonth in
            self?.ruleEditingChanged()
        }
        
        sectionItem.monthlyModeDidChange = { mode in
            self?.ruleEditingChanged()
        }
        
        sectionItem.dayOfTheWeekDidChange = { dayOfTheWeek in
            self?.ruleEditingChanged()
        }
        
        return sectionItem
    }()
    
    lazy var monthsOfYearSectionController: RepeatMonthOfYearSectionController = { [weak self] in
        let sectionItem = RepeatMonthOfYearSectionController()
        sectionItem.monthsOfTheYearChanged = { monthsOfTheYear in
            self?.ruleEditingChanged()
        }
        
        return sectionItem
    }()
    

    // MARK: - 完成后
    lazy var afterCompletionSectionController: RepeatAfterCompletionSectionController = { [weak self] in
        let sectionItem = RepeatAfterCompletionSectionController()
        sectionItem.frequencyDidChange = { _ in
            self?.ruleEditingChanged()
        }
        
        sectionItem.intervalDidChange = { _ in
            self?.ruleEditingChanged()
        }
        
        return sectionItem
    }()
    
    // MARK: - 自选日期
    lazy var specificDateSectionController: RepeatSpecificDateSectionController = {
        let sectionItem = RepeatSpecificDateSectionController()
        sectionItem.selectedDatesDidChange = { [weak self] _ in
            self?.ruleEditingChanged()
        }
        
        return sectionItem
    }()
     
    override var sectionControllers: [TPTableBaseSectionController]? {
        get {
            var sectionControllers = [infoSectionController,
                                      typeSectionController]
            switch ruleType {
            case .regularly:
                sectionControllers.append(frequencySectionController)
                switch frequencySectionController.frequency {
                case .daily:
                    break
                case .weekly:
                    sectionControllers.append(daysOfWeekSectionController)
                case .monthly:
                    sectionControllers.append(daysOfMonthSectionController)
                case .yearly:
                    sectionControllers.append(monthsOfYearSectionController)
                    sectionControllers.append(daysOfMonthSectionController)
                }
            case .afterCompletion:
                sectionControllers.append(afterCompletionSectionController)
            case .specificDates:
                sectionControllers.append(specificDateSectionController)
            }
            
            return sectionControllers
        }
        
        set { }
    }
    
    init(rule: RecurrenceRule?) {
        super.init(style: .insetGrouped)
        guard let rule = rule else {
            return
        }
        
        self.ruleType = rule.getType()
        switch self.ruleType {
        case .regularly:
            /// 频率
            self.frequencySectionController.frequency = rule.getFrequency()
            self.frequencySectionController.interval = rule.getInterval()
            
            /// 周天
            self.daysOfWeekSectionController.weekdays = rule.getWeekdaysOfTheWeek()
            
            /// 月天
            self.daysOfMonthSectionController.monthlyMode = rule.monthlyMode
            self.daysOfMonthSectionController.daysOfTheMonth = rule.getDaysOfTheMonth()
            if let dayOfTheWeek = rule.daysOfTheWeek?.first {
                self.daysOfMonthSectionController.dayOfTheWeek = dayOfTheWeek
            }
            
            /// 年中的月份
            self.monthsOfYearSectionController.monthsOfTheYear = rule.getMonthsOfTheYear()
        case .afterCompletion:
            self.afterCompletionSectionController.frequency = rule.getFrequency()
            self.afterCompletionSectionController.interval = rule.getInterval()
        case .specificDates:
            self.specificDateSectionController.dates = rule.specificDates ?? []
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Custom Repeat")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.preferredContentSize = .Popover.extraLarge
        self.tableView.showsVerticalScrollIndicator = false
        setupActionsBar(actions: [doneAction])
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        wrapperView.height = layoutFrame.maxY - actionsBarHeight
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override func clickDone() {
        self.didEndEditing?(recurrenceRule)
        dismiss(animated: true, completion: nil)
    }
    
    /// 更新计划描述信息
    func updateInfoCellItem() {
        self.infoCellItem.attributedText = recurrenceRule.localizedAttributedDescription()
    }
    
    func updateRuleTypeCellItem() {
        self.typeCellItem.selectedMenuTag = self.ruleType.rawValue
    }
    
    // MARK: - Edit
    var recurrenceRule: RecurrenceRule {
        let frequency = frequencySectionController.frequency
        var rule = RecurrenceRule()
        rule.type = ruleType
        switch ruleType {
        case .regularly:
            rule.frequency = frequency
            rule.interval = frequencySectionController.interval
            switch frequency {
            case .weekly:
                let weekdays = daysOfWeekSectionController.weekdays
                rule.daysOfTheWeek = weekdays.daysOfTheWeek(with: 0)
            case .monthly, .yearly:
                let mode = daysOfMonthSectionController.monthlyMode
                if mode == .onDays {
                    rule.daysOfTheMonth = daysOfMonthSectionController.daysOfTheMonth
                } else {
                    rule.daysOfTheWeek = [daysOfMonthSectionController.dayOfTheWeek]
                }
                
                /// 每年
                if frequency == .yearly {
                    rule.monthsOfTheYear = monthsOfYearSectionController.monthsOfTheYear
                }
            default:
                break
            }
        
        case .afterCompletion:
            rule.frequency = afterCompletionSectionController.frequency
            rule.interval = afterCompletionSectionController.interval
            break
        case .specificDates:
            rule.specificDates = specificDateSectionController.dates
            break
        }
        
        return rule
    }
    
    func ruleEditingChanged() {
        self.updateInfoCellItem()
        if let cell = adapter.cellForItem(infoCellItem) as? TFDescriptionTableCell {
            cell.updateDescription()
        }
        
        self.adapter.performNilUpdate()
    }
    
    
    /// 选择规则类型
    func didSelectRuleType(_ ruleType: RecurrenceRuleType) {
        self.ruleType = ruleType
        self.adapter.performUpdate(with: .fade)
        self.ruleEditingChanged()
    }
}

