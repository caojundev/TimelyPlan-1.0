//
//  TodoFilterDateEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/2.
//

import Foundation

class TodoFilterDateEditViewController: TPTableSectionsViewController,
                                        TPTableSectionControllerDelegate {
 
    var didEndEditing: ((TodoDateFilterValue?) -> Void)?
    
    private lazy var rangeTypeSectionController: TodoFilterDateRangeTypeEditSectionController = {
        let sectionController = TodoFilterDateRangeTypeEditSectionController(rangeType: rangeType)
        sectionController.didSelectRangeType = { [weak self] newRangeType in
            self?.selectRangeType(newRangeType)
        }
        
        return sectionController
    }()
    
    private lazy var specificSectionController: TodoFilterSpecificDateRangeSectionController = {
        let sectionController = TodoFilterSpecificDateRangeSectionController(dateRange: specificDateRange)
        sectionController.didChangeDateRange = { [weak self] newDateRange in
            self?.changeSpecificDateRange(newDateRange)
        }
        
        return sectionController
    }()
    
    private lazy var relativeAnchorDateSectionController: TodoFilterRelativeAnchorDateSectionController = {
        let sectionController = TodoFilterRelativeAnchorDateSectionController(anchorDate: relativeDateRange.anchorDate)
        sectionController.didChangeAnchorDate = { [weak self] newAnchorDate in
            self?.changeRelativeAnchorDate(newAnchorDate)
        }
        
        return sectionController
    }()
    
    private lazy var relativeDateOffsetSectionController: TodoFilterRelativeDateOffsetSectionController = {
        let sectionController = TodoFilterRelativeDateOffsetSectionController(dateOffset: relativeDateRange.offset)
        sectionController.didChangeDateOffset = { [weak self] newDateOffset in
            self?.changeRelativeDateOffset(newDateOffset)
        }
        
        return sectionController
    }()
    
    override var sectionControllers: [TPTableBaseSectionController]? {
        get {
            var sectionControllers: [TPTableBaseSectionController] = [rangeTypeSectionController]
            let rangeType = filterValue.getRangeType()
            if rangeType == .specific {
                sectionControllers.append(specificSectionController)
            } else {
                sectionControllers.append(relativeAnchorDateSectionController)
                sectionControllers.append(relativeDateOffsetSectionController)
            }
        
            return sectionControllers
        }
        
        set {}
    }

    private var rangeType: TodoDateFilterValue.RangeType
 
    private var specificDateRange: TodoSpecificDateRange

    private var relativeDateRange: TodoRelativeDateRange
    
    var filterValue: TodoDateFilterValue {
        var value = TodoDateFilterValue()
        value.rangeType = rangeType
        if rangeType == .specific {
            value.specificDateRange = specificDateRange
        } else {
            value.relativeDateRange = relativeDateRange
        }
        
        return value
    }
    
    init(filterValue: TodoDateFilterValue?) {
        self.rangeType = filterValue?.rangeType ?? .specific
        self.specificDateRange = filterValue?.specificDateRange ?? TodoSpecificDateRange()
        self.relativeDateRange = filterValue?.relativeDateRange ?? TodoRelativeDateRange()
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Date")
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
    
    private func selectRangeType(_ type: TodoDateFilterValue.RangeType) {
        rangeType = type
        adapter.performUpdate(with: .fade, completion: nil)
    }
    
    private func changeSpecificDateRange(_ dateRange: TodoSpecificDateRange) {
        specificDateRange = dateRange
    }
    
    private func changeRelativeAnchorDate(_ anchorDate: TodoRelativeAnchorDate) {
        relativeDateRange.anchorDate = anchorDate
    }
    
    private func changeRelativeDateOffset(_ offset: TodoRelativeDateOffset) {
        relativeDateRange.offset = offset
    }
}
