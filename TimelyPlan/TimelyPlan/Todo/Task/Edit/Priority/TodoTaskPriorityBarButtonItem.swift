//
//  TodoTaskPriorityBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/29.
//

import Foundation
import UIKit

class TodoTaskPriorityBarButtonItem: UIBarButtonItem {
    
    var didSelectPriority: ((TodoTaskPriority) -> Void)? {
        didSet {
            button.didSelectPriority = didSelectPriority
        }
    }
    
    var priority: TodoTaskPriority = .none {
        didSet {
            button.priority = priority
        }
    }
    
    private lazy var button: TodoTaskPriorityButton = {
        let button = TodoTaskPriorityButton()
        button.isTitleHidden = true
        button.preferredPosition = .bottomLeft
        button.permittedPositions = TPPopoverPosition.bottomPopoverPositions
        return button
    }()
    
    init(priority: TodoTaskPriority = .none) {
        super.init()
        self.priority = priority
        self.customView = self.button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
