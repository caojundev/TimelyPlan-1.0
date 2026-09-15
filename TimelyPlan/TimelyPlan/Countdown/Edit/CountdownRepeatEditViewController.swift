//
//  CountdownRepeatEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

class CountdownRepeatEditViewController: TPTableViewController,
                                         TPTableViewAdapterDataSource,
                                         TPTableViewAdapterDelegate {

    var didEndEditing: ((RepeatRule?) -> Void)?
    
    /// 重复规则发生改变
    var repeatRuleDidChange: ((RepeatRule?) -> Void)?
    
    /// 重复条目
    var repeatRule: RepeatRule? {
        if repeatType == .none {
            return nil
        } else {
            let recurrenceRule = repeatType == .custom ? recurrenceRule : nil
            return RepeatRule(type: repeatType, recurrenceRule: recurrenceRule, end: nil)
        }
    }
    
    /// 重复类型
    private var repeatType: RepeatType = .none
    
    /// 自定义重复规则
    private var recurrenceRule: RecurrenceRule?
    
    /// 重复类型列表
    private var repeatTypeLists: [Array<RepeatType>] = [
        [.none],
         [.daily,
          .weekly,
          .monthly,
          .yearly],
         [.custom]
    ]
    
    let date: CountdownDate
    
    init(repeatRule: RepeatRule?, date: CountdownDate) {
        self.date = date
        self.repeatType = repeatRule?.type ?? .none
        self.recurrenceRule = repeatRule?.recurrenceRule
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Repeat")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.view.clipsToBounds = true
        self.preferredContentSize = .Popover.extraLarge
        self.tableView.showsVerticalScrollIndicator = false
        setupActionsBar(actions: [doneAction])
        actionsBar?.backgroundColor = .systemBackground
        adapter.cellStyle.backgroundColor = .systemBackground
        adapter.dataSource = self
        adapter.delegate = self
        adapter.reloadData()
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        self.dismiss(animated: true)
        self.didEndEditing?(repeatRule)
    }
    
    // MARK: - TPTableViewAdapterDataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        var sectionNumbers = [NSNumber]()
        for i in 0..<repeatTypeLists.count {
            sectionNumbers.append(NSNumber(value: i))
        }
        
        return sectionNumbers
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let sectionNumber = sectionObject as? NSNumber else {
            return nil
        }
        
        let section = sectionNumber.intValue
        let repatTypeList = repeatTypeLists[section]
        return repatTypeList.map { $0.rawValue } as [NSString]
    }
    
    // MARK: - TPTableViewAdapterDelegate
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPCircularCheckboxInfoTableCell.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TPCircularCheckboxInfoTableCell else {
            return
        }
        
        cell.subtitleConfig.font = UIFont.boldSystemFont(ofSize: 10.0)
        
        let repeatType = repeatTypeLists[indexPath.section][indexPath.row]
        cell.title = repeatType.title
        
        var subtitle: String?
        if repeatType == .custom {
            cell.accessoryType = .disclosureIndicator
            cell.padding = TableCellLayout.withAccessoryCellPadding
            subtitle = recurrenceRule?.localizedAttributedDescription()?.value.string
        } else {
            cell.accessoryType = .none
            cell.padding = TableCellLayout.withoutAccessoryCellPadding
            subtitle = description(for: repeatType)
        }
        
        cell.subtitle = subtitle
    }
    
    private func description(for repeatType: RepeatType) -> String? {
        let targetDate = date.targetDate
        if date.type == .gregorian {
            return repeatType.subtitle(for: targetDate)
        }
        
        /// 农历日期
        switch repeatType {
        case .weekly:
            return targetDate.weekdaySymbol()
        case .monthly:
            return targetDate.lunarDayString
        case .yearly:
            return targetDate.lunarMonthDayString
        default:
            return nil
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if section > 0 {
            return TPSeparatorTableHeaderFooterView.self
        }
        
        return UITableViewHeaderFooterView.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        let repeatType = repeatTypeLists[indexPath.section][indexPath.row]
        return self.repeatType == repeatType
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        let repeatType = repeatTypeLists[indexPath.section][indexPath.row]
        if repeatType == .custom {
            customizeRepeat()
        } else {
            self.repeatType = repeatType
            adapter.updateCheckmarks()
            repeatRuleDidChange?(repeatRule)
        }
    }
    
    private func reloadCustomRepeatCell() {
        if let indexPath = indexPath(for: .custom) {
            adapter.reloadCell(at: indexPath)
        }
    }
    
    private func indexPath(for repeatType: RepeatType) -> IndexPath? {
        for (section, repeatTypeList) in repeatTypeLists.enumerated() {
            for (row, type) in repeatTypeList.enumerated() {
                if repeatType == type {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - 自定义重复
    /// 自定义重复
    func customizeRepeat() {
        if date.type == .lunar {
            lunarCustomRepeat()
        } else {
            gregorianCustomRepeat()
        }
    }
    
    private func gregorianCustomRepeat() {
        let vc = RepeatCustomViewController(rule: recurrenceRule)
        vc.allowChangeRuleType = false
        vc.didEndEditing = { recurrenceRule in
            self.didEndCustomRule(recurrenceRule)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }
    
    private func lunarCustomRepeat() {
        let vc = CountdownLunarRepeatCustomViewController(rule: recurrenceRule)
        vc.didEndEditing = { recurrenceRule in
            self.didEndCustomRule(recurrenceRule)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }
    
    private func didEndCustomRule(_ recurrenceRule: RecurrenceRule) {
        if recurrenceRule.type == .specificDates {
            let selectedDatesCount = recurrenceRule.specificDates?.count ?? 0
            if selectedDatesCount == 0 {
                /// 未选中日期，不做处理
                return
            }
        }
        
        self.repeatType = .custom
        self.recurrenceRule = recurrenceRule
        self.reloadCustomRepeatCell()
        self.adapter.updateCheckmarks()
        self.view.animateLayout(withDuration: 0.25)
        self.repeatRuleDidChange?(self.repeatRule)
    }
}
