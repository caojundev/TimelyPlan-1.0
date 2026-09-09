//
//  GoalTaskActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

enum GoalTaskActionType: Int, TPMenuRepresentable {
    case steps = 0   /// 步骤
    case records     /// 记录
    case note        /// 备注
    
    static func titles() -> [String] {
        return ["Steps", "Records", "Note"]
    }
}

class GoalTaskActionViewController: TPContainerViewController {
    
    private let infoViewHeight = 75.0
    private let segmentedMenuTopMargin = 15.0
    private let segmentedMenuHeight = 46.0
    private let contentTopMargin = 10.0
    
    private lazy var checkInfoView: GoalTaskCheckInfoView = {
        let view = GoalTaskCheckInfoView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12.0
        view.clipsToBounds = true
        
        view.padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        view.nameHeight = 24.0
        view.detailHeight = 16.0
        view.detailTopMargin = 4.0
        view.progressTopMargin = 8.0
        
        view.didClickCheckbox = { [weak self] _ in
            self?.clickCheckbox()
        }
        
        return view
    }()
    
    /// 选项菜单
    lazy var segmentedMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.normalBackgroundColor = .secondarySystemGroupedBackground
        view.padding = UIEdgeInsets(value: 3.0)
        view.cornerRadius = 12.0
        view.didSelectMenuItem = { [weak self] menuItem in
            let actionType = GoalTaskActionType(rawValue: menuItem.tag) ?? .steps
            self?.selectActionType(actionType)
        }
        
        view.menuItems = GoalTaskActionType.segmentedMenuItems()
        return view
    }()


    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor
    
    /// 当前选中的操作类型
    private var currentActionType: GoalTaskActionType = .steps
    
    /// 步骤内容视图控制器
    private lazy var stepActionViewController: GoalTaskStepActionViewController = {
        return GoalTaskStepActionViewController(interactor: interactor)
    }()
    
    /// 记录内容视图控制器
    private lazy var recordActionViewController: GoalTaskRecordActionViewController = {
        return GoalTaskRecordActionViewController(task: interactor.task)
    }()
    
    /// 备注内容视图控制器
    private lazy var noteActionViewController: GoalTaskNoteActionViewController = {
        return GoalTaskNoteActionViewController(interactor: interactor)
    }()
    
    init(task: GoalTask) {
        self.interactor = GoalTaskEditInteractor(task: task)
        super.init(nibName: nil, bundle: nil)
        self.configureInteractor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.padding = UIEdgeInsets(horizontal: 16.0)
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(checkInfoView)
        view.addSubview(segmentedMenuView)
        updateCheckInfoView()
        setupActionsBar(actions: [doneAction])
        updateContentViewController(with: .none)
        segmentedMenuView.selectMenu(withTag: 0)
    }

    private func updateCheckInfoView() {
        checkInfoView.updateContent(with: interactor.task, animated: false)
        
        let attributedDetail = GoalTaskDetailProvider.attributedDetail(for: interactor.task)
        checkInfoView.detailLabel.update(with: attributedDetail)
    }
    
    /// 配置交互器回调：任务改变刷新信息视图，任务删除则关闭当前视图
    private func configureInteractor() {
        interactor.onTaskChange = { [weak self] _ in
            self?.updateCheckInfoView()
        }
        
        interactor.onTaskDeleted = { [weak self] in
            self?.dismissIfPresented()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        
        checkInfoView.width = layoutFrame.width
        checkInfoView.height = infoViewHeight
        checkInfoView.left = layoutFrame.minX
        checkInfoView.top = 0.0
        
        segmentedMenuView.width = layoutFrame.width
        segmentedMenuView.height = segmentedMenuHeight
        segmentedMenuView.left = layoutFrame.minX
        segmentedMenuView.top = checkInfoView.bottom + segmentedMenuTopMargin
    }
    
    override func contentViewFrame() -> CGRect {
        let layoutFrame = view.safeLayoutFrame()
        let y = infoViewHeight + segmentedMenuTopMargin + segmentedMenuHeight + contentTopMargin
        let h = layoutFrame.height - y - actionsBarHeight
        return CGRect(x: 0.0, y: y, width: view.width, height: h)
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        super.clickDone()
        
    }

    private func clickCheckbox() {
        interactor.toggleCheckbox()
    }
    
    /// 关闭当前展示的视图控制器（任务被删除时调用）
    private func dismissIfPresented() {
        TPImpactFeedback.impactWithSoftStyle()
        guard presentedViewController == nil else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        guard let navigationController = self.navigationController,
              navigationController.isBeingPresented || navigationController.presentingViewController != nil else {
            return
        }
        
        navigationController.dismiss(animated: true, completion: nil)
    }

    private func selectActionType(_ actionType: GoalTaskActionType) {
        if self.currentActionType == actionType {
            return
        }
        
        let animateStyle = SlideStyle.horizontalStyle(fromValue: self.currentActionType.rawValue,
                                                      toValue: actionType.rawValue)
        self.currentActionType = actionType
        self.updateContentViewController(with: animateStyle)
    }
    
    private func updateContentViewController(with style: SlideStyle) {
        let vc: UIViewController
        switch self.currentActionType {
        case .steps:
            vc = stepActionViewController
        case .records:
            vc = recordActionViewController
        case .note:
            vc = noteActionViewController
        }
        
        self.setContentViewController(vc, withAnimationStyle: style)
    }
}
