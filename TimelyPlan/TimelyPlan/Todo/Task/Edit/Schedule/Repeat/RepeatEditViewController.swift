//
//  RepeatTypeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/19.
//

import Foundation
import UIKit

class RepeatEditViewController: TPTableViewController,
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
            return RepeatRule(type: repeatType,
                              recurrenceRule: recurrenceRule,
                              end: repeatEnd,
                              count: occurrenceCount)
        }
    }
    
    /// 重复类型
    private var repeatType: RepeatType = .none
    
    /// 自定义重复规则
    private var recurrenceRule: RecurrenceRule?
    
    /// 重复结束
    private var repeatEnd: RepeatEnd?
    
    /// 重复数目
    private var occurrenceCount: Int?
    
    /// 重复类型列表
    private var repeatTypeLists: [Array<RepeatType>] = [
        [.none],
        [.custom],
        [.daily, .weekly, .weekday, .weekend, .monthly, .yearly],
        [.legalWorkday, .lunarYearly, .ebbinghaus]
    ]
    
    /// 是否显示重复结束
    private var showRepeatEnd: Bool {
        if repeatType == .none {
            return false
        }
        
        if repeatType == .custom {
            if let recurrenceRule = recurrenceRule, recurrenceRule.type == .specificDates {
                /// 自选日期，无重复结束设置
                return false
            }
        }
        
        return true
    }
    
    /// 重复结束
    lazy var repeatEndView: RepeatEndView = {
        let view = RepeatEndView(frame: .zero)
        view.repeatEnd = repeatEnd
        view.repeatEndDidChange = { [weak self] repeatEnd in
            self?.repeatEndChanged(repeatEnd)
        }
        
        return view
    }()
    
    let eventDate: Date
    
    init(repeatRule: RepeatRule?, eventDate: Date?) {
        self.repeatType = repeatRule?.type ?? .none
        self.repeatEnd = repeatRule?.end
        self.recurrenceRule = repeatRule?.recurrenceRule
        self.occurrenceCount = repeatRule?.count
        self.eventDate = eventDate ?? .now
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Repeat")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.view.addSubview(repeatEndView)
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        repeatEndView.width = view.width
        repeatEndView.height = RepeatEndView.defaultHeight
        if showRepeatEnd {
            repeatEndView.alpha = 1.0
            repeatEndView.bottom = actionsBar?.top ?? view.safeLayoutFrame().maxY
            tableView.contentInset = UIEdgeInsets(bottom: repeatEndView.height + actionsBarHeight)
        } else {
            repeatEndView.alpha = 0.0
            repeatEndView.top = view.bounds.height
            tableView.contentInset = UIEdgeInsets(bottom: actionsBarHeight)
        }
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
            subtitle = repeatType.subtitle(for: eventDate)
        }
        
        cell.subtitle = subtitle
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
    
        view.animateLayout(withDuration: 0.25)
    }
    
    // MARK: - 自定义重复
    /// 自定义重复
    func customizeRepeat() {
        let vc = RepeatCustomViewController(rule: recurrenceRule)
        vc.didEndEditing = { recurrenceRule in
            if recurrenceRule.type == .specificDates {
                let selectedDatesCount = recurrenceRule.specificDates?.count ?? 0
                if selectedDatesCount == 0 {
                    /// 未选中日期，不做处理
                    return
                }
                
                /// 自选日期删除重复结束
                self.repeatEnd = nil
            }
            
            self.repeatType = .custom
            self.recurrenceRule = recurrenceRule
            self.reloadCustomRepeatCell()
            self.adapter.updateCheckmarks()
            self.view.animateLayout(withDuration: 0.25)
            self.repeatRuleDidChange?(self.repeatRule)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
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
    
    func repeatEndChanged(_ repeatEnd: RepeatEnd?) {
        self.repeatEnd = repeatEnd
        self.repeatRuleDidChange?(repeatRule)
    }
}
