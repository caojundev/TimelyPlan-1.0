//
//  TodoFilterPriorityEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/25.
//

import Foundation

class TodoFilterPriorityEditViewController: TPTableSectionsViewController,
                                                TPTableSectionControllerDelegate {
    
    /// 选择完成回调
    var didEndEditing: ((Set<TodoTaskPriority>?) -> Void)?
    
    /// 最少选择优先级数目
    var minimumCount = 1
    
    /// 最多选择优先级数目
    var maximumCount = TodoTaskPriority.allCases.count - 1
    
    private lazy var prioritySectionController: TodoFilterPrioritySectionController = {
        let sectionController = TodoFilterPrioritySectionController()
        sectionController.delegate = self
        sectionController.didSelectPriority = { [weak self] priority in
            self?.selectPriority(priority)
        }
        
        return sectionController
    }()

    private(set) var selectedPriorities: Set<TodoTaskPriority> = []
    
    init(priorities: Set<TodoTaskPriority>?) {
        self.selectedPriorities = priorities ?? []
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Priority")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
        sectionControllers = [prioritySectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        super.clickDone()
        
        if selectedPriorities.count > 0 {
            didEndEditing?(selectedPriorities)
        } else {
            didEndEditing?(nil)
        }
    }
    
    func selectPriority(_ priority: TodoTaskPriority) {
        if selectedPriorities.contains(priority) {
            if selectedPriorities.count > minimumCount {
                selectedPriorities.remove(priority)
            }
        } else {
            if selectedPriorities.count < maximumCount {
                selectedPriorities.insert(priority)
            }
        }
        
        adapter.updateCheckmarks()
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        let priority = prioritySectionController.priority(at: index)
        return selectedPriorities.contains(priority)
    }
}

private class TodoFilterPrioritySectionController: TPTableItemSectionController {
    
    var didSelectPriority: ((TodoTaskPriority) -> Void)?
    
    override init() {
        super.init()
        var cellItems = [TPCheckmarkTableCellItem]()
        for priority in TodoTaskPriority.allCases {
            let cellItem = cellItem(with: priority)
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        let priority = priority(at: index)
        didSelectPriority?(priority)
    }
    
    func priority(at index: Int) -> TodoTaskPriority {
        guard let cellItem = item(at: index) as? TPCheckmarkTableCellItem,
              let priority = TodoTaskPriority(rawValue: cellItem.tag) else {
                  return .none
        }
        
        return priority
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let bShow = delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index)
        return bShow ?? false
    }
    
    private func cellItem(with priority: TodoTaskPriority) -> TPCheckmarkTableCellItem {
        let cellItem = TPCheckmarkTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(left: 20.0, right: 10.0)
        cellItem.height = 50.0
        cellItem.tag = priority.rawValue
        cellItem.title = priority.title
        cellItem.imageName = priority.iconName
        cellItem.imageConfig.color = priority.iconColor
        cellItem.imageConfig.margins = UIEdgeInsets(value: 5.0)
        return cellItem
    }
}
