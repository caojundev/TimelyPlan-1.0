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
    
    /// 编辑类型
    private(set) var editType: FocusQuickStartEditType

    /// 工具栏高度
    private let editTypeViewHeight = 64.0
    
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
    
    init(editType: FocusQuickStartEditType = .pomodoro) {
        self.editType = editType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.editTypeView)
        self.navigationItem.leftBarButtonItem = self.chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = self.statisticsBarButtonItem
        self.editTypeView.selectedEditType = self.editType
        self.updateContentViewController(with: .none)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        editTypeView.width = layoutFrame.width
        editTypeView.height = editTypeViewHeight
        editTypeView.bottom = layoutFrame.maxY
        updatePopoverContentSize()
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var popoverContentSize: CGSize {
        return CGSize(kPopoverPreferredContentWidth, 600.0)
    }
    
    override func contentViewFrame() -> CGRect {
        var layoutFrame = view.safeLayoutFrame()
        layoutFrame.size.height = layoutFrame.height - editTypeViewHeight
        return layoutFrame
    }
    
    /// 点击统计
    @objc func clickStatistics(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        self.didClickStatistics?()
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
