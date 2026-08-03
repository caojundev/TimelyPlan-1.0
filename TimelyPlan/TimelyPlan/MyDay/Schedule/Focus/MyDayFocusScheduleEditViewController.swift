//
//  MyDayFocusScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/2.
//

import Foundation
import UIKit

class MyDayFocusScheduleEditViewController: TPTableSectionsViewController {
    
    /// 结束编辑
    var didEndEditing: ((FocusEditingTimer) -> Void)?
    
    /// 当前编辑计时器
    var editingTimer: FocusEditingTimer

    lazy var timeEditSectionController: MyDayTimeEditSectionController = { [weak self] in
        let sectionController = MyDayTimeEditSectionController(startTime: editingTimer.startTime)
        sectionController.onStartTimeChanged = { startTime in
            self?.editingTimer.startTime = startTime
        }
        
        return sectionController
    }()
    
    private let indicatorSize = CGSize(width: 6.0, height: 36.0)
    
    private let infoViewTopMargin = 20.0
    private let infoViewHeight = 60.0
    private let infoViewBottomMargin = 10.0
    private let infoView = TPColorInfoView()

    init(timer: FocusEditingTimer) {
        self.editingTimer = timer
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(infoView)
        setupActionsBar(actions: [doneAction])
        sectionControllers = [timeEditSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
        updateInfoView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: UIEdgeInsets(horizontal: 20.0))
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.top = infoViewTopMargin
        infoView.left = layoutFrame.minX
    }
    
    override func tableViewFrame() -> CGRect {
        var frame = super.tableViewFrame()
        frame.origin.y = frame.origin.y + infoViewTopMargin + infoViewHeight + infoViewBottomMargin
        frame.size.height = frame.size.height - infoViewTopMargin - infoViewHeight - infoViewBottomMargin
        return frame
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func updateInfoView() {
        infoView.colorConfig = .withColor(editingTimer.color, size: indicatorSize)
        infoView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        infoView.subtitleConfig.font = .boldSystemFont(ofSize: 12.0)
        infoView.title = editingTimer.name
        infoView.subtitle = editingTimer.config?.summary
    }
  
    override func clickDone() {
        didEndEditing?(editingTimer)
        dismiss(animated: true, completion: nil)
    }
}
