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

class GoalTaskActionViewController: TPContainerViewController,
                                    GoalTaskActionFooterViewDelegate {
    
    private let infoViewHeight = 82.0
    private let segmentedMenuTopMargin = 15.0
    private let segmentedMenuHeight = 46.0
    private let contentTopMargin = 10.0
    private let footerViewHeight = 60.0
    
    private lazy var checkInfoView: GoalTaskCheckInfoView = {
        let view = GoalTaskCheckInfoView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12.0
        view.clipsToBounds = true
        view.padding = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        view.nameHeight = 24.0
        view.detailHeight = 16.0
        view.detailTopMargin = 4.0
        view.progressTopMargin = 8.0
        view.detailLabel.font = .boldSystemFont(ofSize: 11.0)
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
    
    /// 标题视图
    private lazy var titleView: GoalTaskActionTitleView = {
        let view = GoalTaskActionTitleView()
        view.onClickHandler = { [weak self] in
            self?.clickTitleView()
        }
        
        return view
    }()
    
    /// 底部视图（中间日期 + 右侧更多按钮）
    private lazy var footerView: GoalTaskActionFooterView = {
        let view = GoalTaskActionFooterView()
        view.delegate = self
        return view
    }()
    
    /// 目标任务控制器（执行更多菜单操作，与列表一致）
    private let taskController = GoalTaskController()
    
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
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.padding = UIEdgeInsets(horizontal: 16.0)
        view.addSubview(checkInfoView)
        view.addSubview(segmentedMenuView)
        view.addSubview(footerView)
        updateCheckInfoView()
        updateContentViewController(with: .none)
        segmentedMenuView.selectMenu(withTag: 0)
    }

    private func updateCheckInfoView() {
        checkInfoView.updateContent(with: interactor.task, animated: false)
        
        let attributedDetail = GoalTaskDetailProvider.attributedDetail(for: interactor.task)
        checkInfoView.detailLabel.update(with: attributedDetail)
        updateTitleView()
        updateFooterView()
    }
    
    /// 更新标题视图
    private func updateTitleView() {
        titleView.goalPlan = interactor.task.planFeature
        titleView.sizeToFit()
    }
    
    /// 更新底部视图的日期信息
    private func updateFooterView() {
        footerView.task = interactor.task
        footerView.updateDateInfo()
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
        
        /// 底部视图置于安全区域底部
        footerView.width = view.width
        footerView.height = footerViewHeight + view.safeAreaInsets.bottom
        footerView.left = 0.0
        footerView.bottom = view.height
    }
    
    override func contentViewFrame() -> CGRect {
        let layoutFrame = view.safeLayoutFrame()
        let y = infoViewHeight + segmentedMenuTopMargin + segmentedMenuHeight + contentTopMargin
        let h = layoutFrame.height - y - footerViewHeight
        return CGRect(x: 0.0, y: y, width: view.width, height: h)
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - Event Response
    private func clickTitleView() {
        taskController.moveTask(interactor.task)
    }
    
    private func clickCheckbox() {
        interactor.toggleCheckbox()
    }
    
    // MARK: - GoalTaskActionFooterViewDelegate
    func goalTaskActionFooterViewDidClickFocus(_ view: GoalTaskActionFooterView) {
        TPImpactFeedback.impactWithSoftStyle()
        UIResponder.resignCurrentFirstResponder()
        FocusPresenter.quickStartFocus(for: interactor.task)
    }
    
    /// 点击更多按钮，弹出与任务列表一致的任务操作菜单
    func goalTaskActionFooterViewDidClickMore(_ view: GoalTaskActionFooterView) {
        TPImpactFeedback.impactWithSoftStyle()
        UIResponder.resignCurrentFirstResponder()
        
        let task = interactor.task
        let menuController = GoalTaskMenuController(task: task)
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.taskController.performMenuAction(type, for: task)
        }
        
        menuController.showMenu(from: view.moreButton)
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
