//
//  TodoFilterProgressEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/31.
//

import Foundation

class TodoFilterProgressEditViewController: TPTableSectionsViewController,
                                                TPTableSectionControllerDelegate {
 
    var didEndEditing: ((TodoProgressFilterValue?) -> Void)?
    
    private lazy var offSectionController: TodoFilterProgressOffSectionController = {
        let sectionController = TodoFilterProgressOffSectionController()
        sectionController.delegate = self
        sectionController.didSelectOff = { [weak self] in
            self?.selectOff()
        }
        
        return sectionController
    }()
    
    private lazy var typeSectionController: TodoFilterProgressTypeSectionController = {
        let sectionController = TodoFilterProgressTypeSectionController()
        sectionController.delegate = self
        sectionController.didSelectFilterType = { [weak self] filterType in
            self?.selectFilterType(filterType)
        }
        
        return sectionController
    }()
    
    private lazy var specificSectionController: TodoFilterProgressSpecificSectionController = { [weak self] in
        let value = filterValue.specificValue
        let sectionController = TodoFilterProgressSpecificSectionController(specificValue: value)
        sectionController.didChangeValueType = { valueType in
            self?.changeSpecificValueType(valueType)
        }
        
        sectionController.didChangeSpecificValue = { value in
            self?.changeSpecificValue(value)
        }
        
        return sectionController
    }()

    private(set) var filterValue: TodoProgressFilterValue
    
    override var sectionControllers: [TPTableBaseSectionController]? {
        get {
            var sectionControllers = [offSectionController,
                                      typeSectionController]
            if let filterType = filterValue.filterType, filterType == .setted {
                sectionControllers.append(specificSectionController)
            }
            
            return sectionControllers
        }
        
        set {}
    }
    
    init(filterValue: TodoProgressFilterValue?) {
        self.filterValue = filterValue ?? TodoProgressFilterValue()
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Progress")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
        actionsBar?.backgroundColor = .systemGroupedBackground
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        super.clickDone()
        didEndEditing?(filterValue)
    }
    
    private func selectOff() {
        filterValue.filterType = nil
        adapter.updateCheckmarks()
        adapter.performUpdate(with: .top, completion: nil)
    }
    
    private func selectFilterType(_ filterType: TodoProgressFilterType) {
        filterValue.filterType = filterType
        adapter.updateCheckmarks()
        adapter.performUpdate(with: .top, completion: nil)
    }
    
    private func changeSpecificValueType(_ type: TodoFilterProgressSpecificValueType) {
        if type == .any {
            filterValue.specificValue = nil
        } else {
            filterValue.specificValue = specificSectionController.specificValue
        }
    }
    
    private func changeSpecificValue(_ value: TodoProgressFilterSpecificValue) {
        filterValue.specificValue = value
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        if sectionController == offSectionController {
            return filterValue.filterType == nil
        } else if sectionController == typeSectionController {
            let filterType = typeSectionController.filterType(at: index)
            return filterValue.filterType == filterType
        }
        
        return false
    }
}
