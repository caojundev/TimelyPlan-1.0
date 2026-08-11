//
//  TaskMultipleDateInfoEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/11.
//

import Foundation
import UIKit

class TaskMultipleDateInfoEditViewController: TPTableSectionsViewController,
                                               TPCalendarSingleDateSelectionDelegate {
    
    /// 日期范围视图高度
    private let dateRangeViewHeight = 110.0
    lazy var dateRangeView: TodoMultiDayScheduleDateRangeView = {
        let view = TodoMultiDayScheduleDateRangeView()
        view.didSelectEditType = { [weak self] editType in
            self?.selectDateEditType(editType)
        }

        return view
    }()
    
    /// 日期区块
    lazy var dateSectionController: TodoMultiDayScheduleEditSectionController = {
        let sectionController = TodoMultiDayScheduleEditSectionController()
        sectionController.didChangeDateInfo = { [weak self] dateInfo in
            self?.dateInfoChanged(dateInfo)
        }
        
        return sectionController
    }()
    
    private(set) var dateInfo: TaskDateInfo
    
    init(dateInfo: TaskDateInfo?) {
        if let dateInfo = dateInfo, dateInfo.style == .multiDay {
            self.dateInfo = dateInfo
        } else {
            self.dateInfo = TaskDateInfo(style: .multiDay)
        }
        
        super.init(style: .grouped)
        dateSectionController.dateInfo = self.dateInfo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(dateRangeView)
        self.tableView.showsVerticalScrollIndicator = false
        self.adapter.cellStyle.backgroundColor = .systemBackground
        self.sectionControllers = [dateSectionController]
        self.reloadData()
    }
    
    override func reloadData() {
        super.reloadData()
        self.reloadDateRangeView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dateRangeView.width = view.width
        dateRangeView.height = dateRangeViewHeight
        dateRangeView.origin = .zero
    }
    
    override func tableViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: dateRangeViewHeight,
                      width: view.bounds.width,
                      height: view.bounds.height - dateRangeViewHeight)
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }

    private func selectDateEditType(_ editType: DateRangeEditType) {
        dateSectionController.selectEditType(editType)
    }
    
    /// 更新日期范围视图
    private func reloadDateRangeView() {
        dateRangeView.editType = dateSectionController.editType
        dateRangeView.dateInfo = dateSectionController.dateInfo
    }
    
    func dateInfoChanged(_ dateInfo: TaskDateInfo) {
        self.dateInfo = dateInfo
        dateSectionController.dateInfo = dateInfo
        reloadDateRangeView()
    }
    
}

