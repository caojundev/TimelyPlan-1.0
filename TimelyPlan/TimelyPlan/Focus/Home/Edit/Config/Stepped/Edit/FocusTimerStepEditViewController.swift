//
//  FocusTimerStepEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/18.
//

import Foundation
import UIKit

class FocusTimerStepEditViewController: TPContainerViewController {
    
    /// 结束步骤编辑
    var didEndEditing: ((FocusTimerStep) -> Void)?
    
    /// 编辑类型
    let editType: EditType
    
    /// 初始步骤
    var originStep: FocusTimerStep?
    
    /// 当前编辑的步骤
    private var editingStep: FocusTimerStep {
        return editingViewController.step
    }
    
    private var editingViewController: FocusTimerStepEditContentViewController!
    
    init(step: FocusTimerStep? = nil) {
        self.editType = step == nil ? .create : .modify
        self.originStep = step
        super.init(nibName: nil, bundle: nil)
        
        let step = step ?? FocusTimerStep()
        self.editingViewController = newEditViewController(with: step)
        updateDoneButtonEnabled()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editType == .create {
            self.title = resGetString("New Step")
        } else {
            self.title = resGetString("Edit Step")
        }
        
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        self.contentViewController = editingViewController
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        self.didEndEditing?(editingViewController.step)
        dismiss(animated: true, completion: nil)
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        self.doneBarButtonItem.isEnabled = !editingViewController.isEmptyName
    }
    
    private func newEditViewController(with step: FocusTimerStep) -> FocusTimerStepEditContentViewController {
        let vc = FocusTimerStepEditContentViewController(step: step)
        vc.didChangeStepName = { [weak self] in
            self?.updateDoneButtonEnabled()
        }
        
        return vc
    }
    
}
