//
//  TodoFilterListEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/24.
//

import Foundation

class TodoFilterListEditViewController: TPViewController {
    
    var didEndEditing: ((TodoListFilterValue) -> Void)?
    
    var didChangeFilterValue: ((TodoListFilterValue) -> Void)? {
        get {
            return selectView.didChangeFilterValue
        }
        
        set {
            selectView.didChangeFilterValue = newValue
        }
    }
    
    var filterValue: TodoListFilterValue {
        return selectView.filterValue
    }
    
    private let selectView: TodoFilterListSelectView
    
    init(filterValue: TodoListFilterValue?) {
        let filterValue = filterValue ?? TodoListFilterValue()
        self.selectView = TodoFilterListSelectView(filterValue: filterValue)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("List")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(self.selectView)
        setupActionsBar(actions: [doneAction])
        actionsBar?.backgroundColor = .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        selectView.width = layoutFrame.width
        selectView.height = layoutFrame.height - actionsBarHeight
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        super.clickDone()
        didEndEditing?(filterValue)
    }
}

class TodoFilterListSelectView: TPTableWrapperView,
                                TPTableSectionControllersList,
                                TPTableSectionControllerDelegate {
    
    var didChangeFilterValue: ((TodoListFilterValue) -> Void)?
    
    var sectionControllers: [TPTableBaseSectionController]?
    
    private(set) var filterValue: TodoListFilterValue
    
    /// 收件箱区块控制器
    private lazy var inboxSectionController: TodoListSelectInboxSectionController = {
        let sectionController = TodoListSelectInboxSectionController()
        sectionController.delegate = self
        sectionController.didSelectInbox = { [weak self] in
            self?.selectInbox()
        }
        
        return sectionController
    }()
    
    /// 用户列表区块控制器
    private lazy var userSectionController: TodoListSelectUserSectionController = {
        let sectionController = TodoListSelectUserSectionController()
        sectionController.delegate = self
        sectionController.didSelectList = { [weak self] list in
            self?.selectList(list)
        }
        
        return sectionController
    }()
    

    init(filterValue: TodoListFilterValue) {
        self.filterValue = filterValue
        super.init(frame: .zero, style: .grouped)
        self.backgroundColor = .systemBackground
        self.tableView.backgroundColor = .systemBackground
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.adapter.cellStyle.backgroundColor = .systemBackground
        self.adapter.delegate = self
        self.adapter.dataSource = self
        self.sectionControllers = [inboxSectionController,
                                   userSectionController]
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectInbox() {
        if let includeInbox = filterValue.includeInbox, includeInbox {
            filterValue.includeInbox = false
        } else {
            filterValue.includeInbox = true
        }
        
        didChangeFilterValue?(filterValue)
        adapter.updateCheckmarks()
    }
    
    func selectList(_ list: TodoList?) {
        guard let listId = list?.identifier else {
            return
        }

        var selectedListIds = filterValue.identifiers ?? []
        if selectedListIds.contains(listId) {
            selectedListIds.remove(listId)
        } else {
            selectedListIds.append(listId)
        }
        
        filterValue.identifiers = selectedListIds
        didChangeFilterValue?(filterValue)
        adapter.updateCheckmarks()
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        if sectionController == userSectionController {
            if let list = userSectionController.item(at: index) as? TodoList, let listID = list.identifier {
                return filterValue.identifiers?.contains(listID) ?? false
            }
        } else if sectionController is TodoListSelectInboxSectionController {
            return filterValue.includeInbox ?? false
        }
        
        return false
    }
}
