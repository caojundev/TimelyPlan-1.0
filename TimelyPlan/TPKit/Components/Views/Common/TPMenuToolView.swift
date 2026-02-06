//
//  TPMenuToolView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/21.
//

import Foundation
import UIKit

fileprivate class TPMenuToolButton<T: Hashable & TPMenuRepresentable>: TPDefaultButton {
    
    var actionType: T
    
    init(actionType: T) {
        self.actionType = actionType
        super.init(frame: .zero)
        self.imagePosition = .top
        self.image = actionType.iconImage
        self.title = actionType.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TPMenuToolView<T: Hashable & TPMenuRepresentable>: UIView {

    /// 禁用类型
    var disabledTypes: [T]? {
        didSet {
            if !shouldUpdateButtons {
                self.updateButtonEnabled()
            }
        }
    }

    /// 工具栏显示条目数
    var preferredItemsCount: Int = 5 {
        didSet {
            guard preferredItemsCount != oldValue else {
                return
            }
            
            shouldUpdateButtons = true
            setNeedsLayout()
        }
    }
    
    /// 选中菜单动作类型
    var didSelectActionType: ((T, UIView) -> Void)?
    
    private lazy var otherButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.imagePosition = .top
        button.image = resGetImage("ellipsis_24")
        button.title = resGetString("Others")
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()

    /// 是否需要更新按钮
    private var shouldUpdateButtons: Bool = true
    
    /// 当前选中菜单动作类型
    var actionTypes: [T] {
        didSet {
            guard actionTypes != oldValue else {
                return
            }
            
            shouldUpdateButtons = true
            setNeedsLayout()
        }
    }
    
    convenience init(actionTypes: [T]) {
        self.init(frame: .zero, actionTypes: actionTypes)
    }
    
    init(frame: CGRect, actionTypes: [T]) {
        self.actionTypes = actionTypes
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 20.0, vertical: 5.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldUpdateButtons {
            shouldUpdateButtons = false
            setupButtons()
        }
        
        guard buttons.count > 0 else {
            return
        }
        
        let layoutFrame = self.safeAreaFrame().inset(by: self.padding)
        let buttonWidth = layoutFrame.width / CGFloat(buttons.count)
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(x: layoutFrame.minX + CGFloat(index) * buttonWidth,
                                  y: layoutFrame.minY,
                                  width: buttonWidth,
                                  height: layoutFrame.height)
        }
    }
    
    private var buttons = [TPDefaultButton]()
    
    private func setupButtons() {
        for button in self.buttons {
            button.removeFromSuperview()
        }
        
        var buttons = [TPDefaultButton]()
        if let displayActionTypes = displayActionTypes() {
            for actionType in displayActionTypes {
                let button = TPMenuToolButton(actionType: actionType)
                button.addTarget(self,
                                 action: #selector(clickActionButton(_:)),
                                 for: .touchUpInside)
                button.isEnabled = !(disabledTypes?.contains(actionType) ?? false)
                buttons.append(button)
                addSubview(button)
                updateStyle(for: button, with: actionType)
            }
        }
        
        if shouldShowMoreButton() {
            self.updateStyle(for: otherButton, with: nil)
            otherButton.isEnabled = isMoreButtonEnabled()
            buttons.append(otherButton)
            addSubview(otherButton)
        }
        
        self.buttons = buttons
        setNeedsLayout()
    }
    
    /// 更新按钮样式
    private func updateStyle(for button: TPDefaultButton, with type: T? = nil) {
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        if let type = type, type.actionStyle == .destructive {
            button.imageConfig.color = .danger6
            button.titleConfig.textColor = .danger6
        } else {
            let color: UIColor? = resGetColor(.title)
            button.imageConfig.color = color
            button.titleConfig.textColor = color
        }
    }
    
    /// 更新按钮的可用状态
    private func updateButtonEnabled() {
        let disabledTypes = self.disabledTypes ?? []
        for button in buttons {
            if let button = button as? TPMenuToolButton<T> {
                let isEnabled = !disabledTypes.contains(button.actionType)
                button.isEnabled = isEnabled
            } else {
                button.isEnabled = isMoreButtonEnabled()
            }
        }
    }
    
    /// 显示的类型
    private func displayActionTypes() -> [T]? {
        let count: Int
        if shouldShowMoreButton() {
            count = preferredItemsCount - 1
        } else {
            count = preferredItemsCount
        }
        
        let endIndex = min(count, actionTypes.count)
        return Array(actionTypes[0..<endIndex])
    }
    
    /// 是否显示更多按钮
    private func shouldShowMoreButton() -> Bool {
        if self.actionTypes.count > preferredItemsCount {
            return true
        }
        
        return false
    }
    
    /// 更多按钮是否可用
    private func isMoreButtonEnabled() -> Bool {
        guard let enabledMoreActionTypes = enabledMoreActionTypes() else {
            return false
        }
        
        return enabledMoreActionTypes.count > 0
    }
    
    /// 更多显示类型
    private func moreActionTypes() -> [T]? {
        guard shouldShowMoreButton() else {
            return nil
        }
        
        let fromIndex = max(preferredItemsCount - 1, 0)
        return Array(actionTypes[fromIndex..<actionTypes.count])
    }
    
    /// 可用的更多类型
    private func enabledMoreActionTypes() -> [T]? {
        guard let moreActionTypes = moreActionTypes() else {
            return nil
        }
        
        guard let disabledTypes = disabledTypes else {
            return moreActionTypes
        }

        var results = [T]()
        for moreActionType in moreActionTypes {
            if !disabledTypes.contains(moreActionType) {
                results.append(moreActionType)
            }
        }
        
        return results.count > 0 ? results : nil
    }

    // MARK: - Event Response
    @objc func clickActionButton(_ button: TPDefaultButton) {
        guard let button = button as? TPMenuToolButton<T> else {
            return
        }
        
        didSelectActionType?(button.actionType, button)
    }
    
    @objc func clickMore(_ button: UIButton){
        guard let moreActionTypes = enabledMoreActionTypes() else {
            return
        }
        
        let menuItem = TPMenuItem.item(with: moreActionTypes)
        let menuListVC = TPMenuListViewController()
        menuListVC.didSelectMenuAction = { action in
            var actionType: T? = nil
            if T.RawValue.self == String.self {
                actionType = T(rawValue: action.identifier as! T.RawValue)
            } else if T.RawValue.self == Int.self {
                actionType = T(rawValue: action.tag as! T.RawValue)
            }
     
            if let actionType = actionType {
                self.didSelectActionType?(actionType, button)
            }
        }
        
        menuListVC.menuItems = [menuItem]
        menuListVC.popoverShow(from: button,
                               sourceRect: button.bounds,
                               isSourceViewCovered: false,
                               preferredPosition: .topLeft,
                               permittedPositions: [.topLeft],
                               animated: true,
                               completion: nil)
    }
}
