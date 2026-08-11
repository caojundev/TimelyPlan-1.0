//
//  TaskSingleDateInfoEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/11.
//

import Foundation
import UIKit

class TaskSingleDateInfoEditViewController: TPTableSectionsViewController,
                                               TPCalendarSingleDateSelectionDelegate {
    
    /// 日期信息视图
    private let dateInfoViewHeight = 40.0
    private lazy var dateInfoView: TaskScheduleEditInfoView = {
        let view = TaskScheduleEditInfoView(frame: .zero)
        view.didClickDate = { [weak self] in
            self?.dateSectionController.setStartDateVisible()
        }
        
        return view
    }()
    
    /// 日期区块
    private lazy var dateSectionController: TaskScheduleEditDateSectionController = {
        let sectionController = TaskScheduleEditDateSectionController()
        sectionController.didChangeDateInfo = { [weak self] dateInfo in
            self?.dateInfoChanged(dateInfo)
        }
        
        return sectionController
    }()
    
    
    private(set) var dateInfo: TaskDateInfo
    
    init(dateInfo: TaskDateInfo?) {
        if let dateInfo = dateInfo, dateInfo.style == .singleDay {
            self.dateInfo = dateInfo
        } else {
            self.dateInfo = TaskDateInfo(style: .singleDay)
        }
        
        super.init(style: .grouped)
        dateSectionController.dateInfo = self.dateInfo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(dateInfoView)
        tableView.showsVerticalScrollIndicator = false
        adapter.cellStyle.backgroundColor = .systemBackground
        sectionControllers = [dateSectionController]
        reloadData()
        updateDateInfoView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dateInfoView.width = view.width
        dateInfoView.height = dateInfoViewHeight
    }
    
    override func tableViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: dateInfoViewHeight,
                      width: view.width,
                      height: view.height - dateInfoViewHeight)
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    private func updateDateInfoView() {
        dateInfoView.schedule = TaskSchedule(dateInfo: dateInfo,
                                             reminder: nil,
                                             repeatRule: nil)
    }
    
    // MARK: - 编辑内容改变
    private func dateInfoChanged(_ dateInfo: TaskDateInfo) {
        self.dateInfo = dateInfo
        updateDateInfoView()
    }
}

