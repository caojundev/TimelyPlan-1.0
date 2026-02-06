//
//  TPViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/25.
//

import Foundation
import UIKit

class TPViewController: UIViewController {
    
    /// 返回
    lazy var backButtonItem: UIBarButtonItem = {
        let image = resGetImage("chevron_left_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .done,
                                         target: self,
                                         action: #selector(clickBack(_:)))
        return buttonItem
    }()
    
    /// 取消按钮
    lazy var chevronDownCancelButtonItem: UIBarButtonItem = {
        let image = resGetImage("chevron_down_24")
        let buttonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didClickCancel))
        return buttonItem
    }()
    
    /// 添加按钮
    lazy var addBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("plus_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .done,
                                         target: self,
                                         action: #selector(clickAdd))
        return buttonItem
    }()
    
    /// 完成按钮
    lazy var doneBarButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(clickDone))
        return buttonItem
    }()
    
    /// 保存按钮
    lazy var saveButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                         target: self,
                                         action: #selector(didClickSave))
        buttonItem.style = .done
        return buttonItem
    }()
    
    private(set) var isFirstAppearance = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppearance {
            isFirstAppearance = false
            handleFirstAppearance()
        }
    }
    
    open func handleFirstAppearance() {
        // 默认实现什么都不做
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutActionsBar()
    }
    
    override func themeDidChange() {
        updateBackgroundTheme()
        updateNavigationBarTheme()
    }
    
    // MARK: - ActionsBar
    var actionsBar: TPButtonActionsBar?
    
    lazy var cancelAction: TPButtonAction = {
        let action = TPButtonAction(type: .cancel,
                                    title: resGetString("Cancel")) { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }
        
        return action
    }()
    
    lazy var doneAction: TPButtonAction = {
        let action = TPButtonAction(title:  resGetString("Done")) {  [weak self] action in
            self?.clickDone()
        }
        
        return action
    }()

    var actionsBarHeight: CGFloat = 72.0
    
    /// 内容区域frame
    var contentFrame: CGRect {
        var layoutFrame = view.bounds
        if actionsBar != nil {
            layoutFrame.size.height = layoutFrame.height - actionsBarHeight
        }
        
        return layoutFrame
    }
    
    func setupActionsBar(actions: [TPButtonAction]) {
        removeActionsBar()
        let actionsBar = TPButtonActionsBar(actions: actions)
        actionsBar.backgroundColor = .clear
        var contentView: UIView = self.view
        if let view = self.view as? UIVisualEffectView {
            contentView = view.contentView
        }
        
        contentView.addSubview(actionsBar)
        self.actionsBar = actionsBar
        view.setNeedsLayout()
    }
    
    func removeActionsBar() {
        actionsBar?.removeFromSuperview()
    }

    func layoutActionsBar() {
        if let actionsBar = actionsBar {
            let layoutFrame = view.safeLayoutFrame()
            actionsBar.width = layoutFrame.width
            actionsBar.height = actionsBarHeight
            actionsBar.bottom = layoutFrame.maxY
            actionsBar.left = layoutFrame.minX
        }
    }
    
    // MARK: - Notification
    func addAppLifeCycleNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    func removeAppLifeCycleNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
    }
    
    @objc func appDidBecomeActive() {
        
    }
    
    @objc func appDidEnterBackground() {
        
    }
    

    // MARK: - Event Response
    @objc func clickBack(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithSoftStyle()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func clickAdd() {
        TPImpactFeedback.impactWithSoftStyle()
    }
    
    @objc func clickDone() {
        TPImpactFeedback.impactWithSoftStyle()
        
        /// 取消第一响应者
        UIResponder.resignCurrentFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didClickCancel() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didClickSave() {
        TPImpactFeedback.impactWithSoftStyle()
        
        /// 取消第一响应者
        UIResponder.resignCurrentFirstResponder()
        dismiss(animated: true, completion: nil)
    }
}
