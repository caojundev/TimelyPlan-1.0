//
//  TodoScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/21.
//

import Foundation
import UIKit

enum TodoScheduleType: Int, TPMenuRepresentable {
    case singleDay   /// 单日
    case multipleDays /// 多日
    
    var title: String {
        switch self {
        case .singleDay:
            return resGetString("Single Day")
        case .multipleDays:
            return resGetString("Multiple Days")
        }
    }
}

class TodoScheduleEditViewController: TPContainerViewController {
    
    /// 结束计划编辑
    var didEndEditing: ((TaskSchedule?) -> Void)?
    
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
    lazy var singleScheduleEditViewController: TodoSingleScheduleEditViewController = {
        let viewController = TodoSingleScheduleEditViewController(schedule: self.schedule)
        return viewController
    }()
    
    /// 跨天计划编辑
    lazy var multipleScheduleEditViewController: TodoMultipleScheduleEditViewController = {
        let viewController = TodoMultipleScheduleEditViewController(schedule: self.schedule)
        return viewController
    }()
    
    private var schedule: TaskSchedule?
    
    init(schedule: TaskSchedule?) {
        self.showClearButton = schedule != nil
        self.schedule = schedule
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.segmentedMenuView
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        preferredContentSize = .Popover.extraLarge
        setupActionsBar(actions: [doneAction])
        updateRightNavigationItem()
        updateContentViewController(with: .none)
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
        super.clickDone()
        
    }
    
    @objc private func clickClear() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
        didEndEditing?(nil)
    }
    
    private var scheduleType: TodoScheduleType = .singleDay
    
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
            vc = singleScheduleEditViewController
        } else {
            vc = multipleScheduleEditViewController
        }

        self.setContentViewController(vc, withAnimationStyle: style)
    }
    
    
}
