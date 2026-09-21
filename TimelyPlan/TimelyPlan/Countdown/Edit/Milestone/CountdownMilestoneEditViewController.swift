//
//  CountdownMilestoneEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/21.
//

import Foundation
import UIKit

/// 里程碑编辑视图控制器
class CountdownMilestoneEditViewController: TPTableSectionsViewController {
    
    /// 结束编辑里程碑
    var didEndEditing: (([CountdownMilestone]) -> Void)?
    
    /// 里程碑改变
    var milestonesChanged: (([CountdownMilestone]) -> Void)?
    
    /// 里程碑区块
    private lazy var milestoneSectionController: CountdownMilestoneEditSectionController = {
        let sectionController = CountdownMilestoneEditSectionController(milestones: self.milestones, date: self.date)
        sectionController.canAddMilestone = { [weak self] in
            return self?.canAddNewMilestone() ?? false
        }
        
        sectionController.didClickCustom = { [weak self] in
            self?.createCustomMilestone()
        }
        
        sectionController.milestonesDidChange = { [weak self] milestones in
            self?.milestonesDidChange(milestones)
        }
        
        return sectionController
    }()
    
    /// 里程碑
    private(set) var milestones: [CountdownMilestone]
    
    /// 最多里程碑数目
    private let maximumMilestonesCount = 5
    
    let date: CountdownDate
    
    init(milestones: [CountdownMilestone], date: CountdownDate) {
        self.milestones = milestones
        self.date = date
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Milestones")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.tableView.showsVerticalScrollIndicator = false
        self.preferredContentSize = .Popover.extraLarge
        self.setupActionsBar(actions: [doneAction])
        
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.separatorColor = Color(0xaaaaaa, 0.1)
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        
        sectionControllers = [milestoneSectionController]
        adapter.reloadData()
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        dismiss(animated: true, completion: nil)
        didEndEditing?(milestones)
    }
    
    // MARK: - 自定义里程碑
    private func createCustomMilestone() {
        let milestone = CountdownMilestone(interval: 1, unit: .year)
        let vc = CountdownMilestonePickerViewController(milestone: milestone)
        vc.didPickMilestone = { [weak self] milestone in
            self?.milestoneSectionController.didCreateMilestone(milestone)
        }
        
        vc.popoverShow()
    }
    
    // MARK: - 里程碑改变
    func milestonesDidChange(_ milestones: [CountdownMilestone]) {
        self.milestones = milestones
        milestonesChanged?(milestones)
    }
    
    /// 是否可以添加新里程碑
    private func canAddNewMilestone() -> Bool {
        return milestoneSectionController.milestonesCount < maximumMilestonesCount
    }
    
}
