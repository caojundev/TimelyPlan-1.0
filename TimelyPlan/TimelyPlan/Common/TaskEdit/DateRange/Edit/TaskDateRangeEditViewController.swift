//
//  TaskDateRangeEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/23.
//

import Foundation
import UIKit

class TaskDateRangeEditViewController: TPTableSectionsViewController,
                                        TPCalendarSingleDateSelectionDelegate {
    
    /// 日期范围改变
    var dateRangeChanged: ((DateRange) -> Void)?
    
    /// 结束编辑
    var didEndEditing: ((DateRange) -> Void)?
    
    
    var canDeleteStart: Bool {
        get { return dateRangeSegmentedView.canDeleteStart }
        set { dateRangeSegmentedView.canDeleteStart = newValue }
    }
    
    var canDeleteEnd: Bool {
        get { return dateRangeSegmentedView.canDeleteEnd }
        set { dateRangeSegmentedView.canDeleteEnd = newValue }
    }
    
    lazy var dateRangeSegmentedView: TPDateRangeSegmentedView = {
        let view = TPDateRangeSegmentedView()
        view.clipsToBounds = true
        view.didClickDelete = { [weak self] editType in
            self?.sectionController.deleteDate(editType: editType)
        }

        view.didSelectEditType = { [weak self] editType in
            self?.sectionController.didSelectEditType(editType)
        }

        return view
    }()
    
    private let segmentedMargin = 10.0
    
    private let separatorView = UIView()
    
    lazy var sectionController: TaskDateRangeEditSectionController = {
        let sectionController = TaskDateRangeEditSectionController()
        sectionController.dateRangeChanged = { [weak self] dateRange in
            self?.sectionController.dateRange = dateRange
            self?.reloadDateRangeView()
            self?.dateRangeChanged?(dateRange)
        }
        
        return sectionController
    }()
    
    
    init(dateRange: DateRange?, editType: DateRangeEditType = .end) {
        super.init(style: .grouped)
        self.sectionController.editType = editType
        self.sectionController.dateRange = dateRange ?? DateRange()
        self.sectionControllers = [sectionController]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Date Range")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.view.addSubview(dateRangeSegmentedView)
        self.separatorView.backgroundColor = Color(0x888888, 0.1)
        self.view.addSubview(separatorView)
        self.setupActionsBar(actions: [doneAction])
        self.adapter.cellStyle.backgroundColor = .systemBackground
        self.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dateRangeSegmentedView.width = view.width - 20.0
        dateRangeSegmentedView.sizeToFit()
        dateRangeSegmentedView.layer.cornerRadius = 12.0
        dateRangeSegmentedView.alignHorizontalCenter()
        
        separatorView.width = view.width
        separatorView.height = 0.8
        separatorView.top = dateRangeSegmentedView.bottom + segmentedMargin
    }
    
    override func tableViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: dateRangeSegmentedView.segmentedHeight + segmentedMargin,
                      width: view.bounds.width,
                      height: view.bounds.height - 90.0)
    }
    
    override func reloadData() {
        super.reloadData()
        self.reloadDateRangeView()
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        TPImpactFeedback.impactWithSoftStyle()
        didEndEditing?(sectionController.dateRange)
        dismiss(animated: true, completion: nil)
    }
    
    /// 更新日期范围视图
    private func reloadDateRangeView() {
        dateRangeSegmentedView.editType = sectionController.editType
        dateRangeSegmentedView.dateRange = sectionController.dateRange
    }
}
