//
//  FocusQuickStartViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/26.
//

import Foundation
import UIKit

enum FocusQuickStartEditType: Int, Comparable, TPMenuRepresentable {
    case pomodoro  /// 番茄钟
    case countdown /// 倒计时
    case stopwatch /// 正计时
    case custom    /// 自定义计时器
    
    static func titles() -> [String] {
        return ["Pomodoro",
                "Countdown",
                "Stopwatch",
                "Custom Timer"]
    }
    
    var iconName: String? {
        switch self {
        case .pomodoro:
            return "focus_timer_pomodoro_24"
        case .countdown:
            return "focus_timer_countdown_24"
        case .stopwatch:
            return "focus_timer_stopwatch_24"
        case .custom:
            return "focus_timer_custom_24"
        }
    }
    
    static func < (lhs: FocusQuickStartEditType, rhs: FocusQuickStartEditType) -> Bool {
        return  lhs.rawValue < rhs.rawValue
    }
    
}

class FocusQuickStartViewController: TPContainerViewController {

    /// 选中计时器
    var didPickTimer: ((FocusTimerRepresentable) -> Void)?
    
    /// 点击统计
    var didClickStatistics: (() -> Void)?

    /// 点击查看记录
    var didClickRecord: (() -> Void)?
    
    /// 绑定任务特征信息
    var taskFeature: TaskFeature?
    
    /// 编辑类型
    private(set) var editType: FocusQuickStartEditType

    /// 工具栏高度
    private let editTypeViewHeight = 58.0
    
    /// 编辑类型视图
    private lazy var editTypeView: FocusQuickStartTypeView = { [weak self] in
        let view = FocusQuickStartTypeView(frame: .zero)
        view.didSelectEditType = { editType in
            self?.selectEditType(editType)
        }
        
        return view
    }()
    
    /// 统计按钮
    lazy var statisticsBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("chart_bar_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(clickStatistics(_:)))
        return buttonItem
    }()
    
    /// 查看专注记录
    lazy var recordBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("focus_quickStart_record_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(clickViewRecord(_:)))
        return buttonItem
    }()
    
    /// 任务信息视图
    private var taskInfoViewHeight = 40.0
    private lazy var taskInfoView: TPInfoView = {
        let view = TPInfoView()
        view.padding = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 5.0, right: 16.0)
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 13.0)
        view.titleConfig.numberOfLines = 1
        view.titleConfig.textAlignment = .center
        view.addSeparator(position: .bottom)
        return view
    }()
    
    init(editType: FocusQuickStartEditType = .pomodoro, taskFeature: TaskFeature?) {
        self.editType = editType
        self.taskFeature = taskFeature
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.taskInfoView)
        self.view.addSubview(self.editTypeView)
        self.navigationItem.leftBarButtonItem = self.chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItems = [self.statisticsBarButtonItem,
                                                   self.recordBarButtonItem]
        self.editTypeView.selectedEditType = self.editType
        self.updateContentViewController(with: .none)
        self.updateTaskInfoView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        taskInfoView.width = layoutFrame.width
        taskInfoView.height = taskInfoViewHeight
        taskInfoView.origin = layoutFrame.origin
        
        editTypeView.width = layoutFrame.width
        editTypeView.height = editTypeViewHeight
        editTypeView.bottom = layoutFrame.maxY
        updatePopoverContentSize()
    }

    override func contentViewFrame() -> CGRect {
        let layoutFrame = view.safeLayoutFrame()
        let y = layoutFrame.minY + taskInfoViewHeight
        let h = layoutFrame.height - editTypeViewHeight - taskInfoViewHeight
        return CGRect(x: layoutFrame.minX,
                      y: y,
                      width: layoutFrame.width,
                      height: h)
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var popoverContentSize: CGSize {
        return CGSize(kPopoverPreferredContentWidth, 640.0)
    }
    
    private func updateTaskInfoView() {
        guard let taskFeature = taskFeature else {
            taskInfoViewHeight = 0.0
            taskInfoView.isHidden = true
            return
        }

        let taskName = taskFeature.snapshotName ?? resGetString("Untitled Task")
        if let taskImage = taskFeature.type.iconImage(with: .mini) {
            let taskInfo: ASAttributedString = .string(image: taskImage,
                                                       imageSize: .size(3),
                                                       imageColor: resGetColor(.title),
                                                       trailingText: taskName,
                                                       separator: " ")
            taskInfoView.title = taskInfo
        } else {
            taskInfoView.title = taskName
        }
    }
    
    @objc func clickStatistics(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        self.didClickStatistics?()
    }
    
    @objc func clickViewRecord(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        self.didClickRecord?()
    }

    // MARK: - 选中编辑类型
    func selectEditType(_ editType: FocusQuickStartEditType) {
        guard self.editType != editType else {
            return
        }
        
        let style = SlideStyle.horizontalStyle(fromValue: self.editType, toValue: editType)
        self.editType = editType
        self.updateContentViewController(with: style)
    }
    
    private func updateContentViewController(with animateStyle: SlideStyle) {
        let viewController = self.viewController(editType: self.editType)
        self.setContentViewController(viewController, withAnimationStyle: animateStyle)
        self.title = editType.title
    }
    
    private func viewController(editType: FocusQuickStartEditType) -> UIViewController {
        switch editType {
        case .pomodoro:
            return systemTimerViewController(timerType: .pomodoro)
        case .countdown:
            return systemTimerViewController(timerType: .countdown)
        case .stopwatch:
            return systemTimerViewController(timerType: .stopwatch)
        case .custom:
            let vc = FocusQuickStartUserTimerViewController()
            vc.didSelectTimer = {[weak self] userTimer in
                self?.pickTimer(userTimer)
            }
            
            return vc
        }
    }
    
    private func systemTimerViewController(timerType: FocusTimerType) -> FocusQuickStartSystemTimerViewController {
        let vc = FocusQuickStartSystemTimerViewController(timerType: timerType)
        vc.didClickStart = { [weak self] systemTimer in
            self?.pickTimer(systemTimer)
        }
        
        return vc
    }
    
    private func pickTimer(_ timer: FocusTimerRepresentable) {
        self.dismiss(animated: true) { [weak self] in
            self?.didPickTimer?(timer)
        }
    }
    
}
