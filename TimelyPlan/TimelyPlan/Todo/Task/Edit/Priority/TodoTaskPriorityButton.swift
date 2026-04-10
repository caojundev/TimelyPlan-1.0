//
//  TodoTaskPriorityButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/26.
//

import Foundation

class TodoTaskPriorityButton: TPDefaultButton {

    var didSelectPriority: ((TodoTaskPriority) -> Void)?
    
    var priority: TodoTaskPriority {
        didSet {
            updateImageTitle()
        }
    }

    /// 是否显示标题
    var isTitleHidden: Bool = false {
        didSet {
            updateTitle()
        }
    }
    
    var preferredPosition: TPPopoverPosition = .topRight
    
    var permittedPositions: [TPPopoverPosition] = TPPopoverPosition.topPopoverPositions
    
    init(priority: TodoTaskPriority = .none) {
        self.priority = priority
        super.init(frame: .zero)
        self.padding = .zero
        self.normalBackgroundColor = .clear
        self.selectedBackgroundColor = .clear
        self.updateImageTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImageTitle() {
        self.image = priority.iconImage
        self.imageConfig.color = priority.iconColor
        self.titleConfig.textColor = priority.titleColor
        self.updateTitle()
    }
    
    func updateTitle() {
        if isTitleHidden || priority == .none {
            self.title = nil
        } else {
            self.title = priority.title
        }
    }

    override func didTouchUpInside() {
        super.didTouchUpInside()
        
        let popoverView = TPMenuListPopoverView()
        let menuItem = TPMenuItem.item(with: TodoTaskPriority.priorities) { _, action in
            action.handleBeforeDismiss = true
        }
        
        popoverView.menuItems = [menuItem]
        popoverView.didSelectMenuAction = { action in
            guard let priority = TodoTaskPriority(rawValue: action.tag) else {
                return
            }
            
            self.selectPriority(priority)
        }
        
        popoverView.show(from: self,
                         sourceRect: self.bounds,
                         isCovered: false,
                         preferredPosition: preferredPosition,
                         permittedPositions: permittedPositions,
                         animated: true)
    }
    
    func selectPriority(_ priority: TodoTaskPriority) {
        guard self.priority != priority else {
            return
        }
        
        self.priority = priority
        self.didSelectPriority?(priority)
    }
    
}
