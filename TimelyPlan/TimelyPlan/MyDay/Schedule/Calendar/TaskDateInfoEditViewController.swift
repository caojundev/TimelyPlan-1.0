//
//  TaskDateInfoEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/11.
//

import Foundation
import UIKit

class TaskDateInfoEditViewController: TPContainerViewController {
    
    /// 结束计划编辑
    var didEndEditing: ((TaskDateInfo?) -> Void)?
    
    /// 选项菜单
    lazy var segmentedMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.padding = UIEdgeInsets(value: 3.0)
        view.buttonHeight = 30.0
        view.minButtonWidth = 64.0
        view.didSelectMenuItem = { [weak self] menuItem in
            let scheduleType = TodoScheduleType(rawValue: menuItem.tag) ?? .singleDay
            self?.didSelectScheduleType(scheduleType)
        }
        
        view.menuItems = TodoScheduleType.segmentedMenuItems()
        view.sizeToFit()
        return view
    }()

    /// 显示清除按钮
    var showClearButton: Bool {
        didSet {
            updateRightNavigationItem()
        }
    }
    
    /// 清除按钮
    private lazy var clearBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Clear"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear))
        item.tintColor = .redPrimary
        return item
    }()
    
    /// 单日计划编辑
    lazy var singleDateInfoEditViewController: TaskSingleDateInfoEditViewController = {
        let viewController = TaskSingleDateInfoEditViewController(dateInfo: dateInfo)
        return viewController
    }()
    
    /// 跨天计划编辑
    lazy var multipleDateInfoEditViewController: TaskMultipleDateInfoEditViewController = {
        let viewController = TaskMultipleDateInfoEditViewController(dateInfo: dateInfo)
        return viewController
    }()
    
    private var scheduleType: TodoScheduleType
    
    private var dateInfo: TaskDateInfo?
    
    init(dateInfo: TaskDateInfo?) {
        self.showClearButton = dateInfo != nil
        self.dateInfo = dateInfo
        
        if let dateInfo = dateInfo, dateInfo.style == .multiDay {
            self.scheduleType = .multiDay
        } else {
            self.scheduleType = .singleDay
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentedMenuView
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        preferredContentSize = .Popover.extraLarge
        setupActionsBar(actions: [doneAction])
        updateRightNavigationItem()
        updateContentViewController(with: .none)
        segmentedMenuView.selectMenu(withTag: self.scheduleType.rawValue)
    }
    
    override func contentViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: 0.0,
                      width: view.width,
                      height: view.height - actionsBarHeight)
    }
    
    func updateRightNavigationItem() {
        self.navigationItem.rightBarButtonItem = showClearButton ? clearBarButtonItem : nil
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        var dateInfo: TaskDateInfo?
        if scheduleType == .singleDay {
            dateInfo = singleDateInfoEditViewController.dateInfo
        } else {
            dateInfo = multipleDateInfoEditViewController.dateInfo
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true) { [weak self] in
            self?.didEndEditing?(dateInfo)
        }
    }
    
    @objc private func clickClear() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
        didEndEditing?(nil)
    }

    private func didSelectScheduleType(_ scheduleType: TodoScheduleType) {
        if self.scheduleType == scheduleType {
            return
        }
        

        let animateStyle = SlideStyle.horizontalStyle(fromValue: self.scheduleType.rawValue,
                                                      toValue: scheduleType.rawValue)
        self.scheduleType = scheduleType
        self.updateContentViewController(with: animateStyle)
    }
    
    private func updateContentViewController(with style: SlideStyle) {
        let vc: UIViewController
        if self.scheduleType == .singleDay {
            vc = singleDateInfoEditViewController
        } else {
            vc = multipleDateInfoEditViewController
        }

        self.setContentViewController(vc, withAnimationStyle: style)
    }
}
