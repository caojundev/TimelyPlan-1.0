//
//  TodoSearchFilterRuleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/26.
//

import Foundation
import UIKit

class TodoSearchFilterRuleEditViewController: TodoFilterRuleEditViewController {
    
    /// 点击清除
    var didClickClear: (() -> Void)?
    
    /// 清除按钮
    private lazy var clearBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: resGetString("Clear"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear))
        item.tintColor = .redPrimary
        return item
    }()
    
    private let showClearButton: Bool
    
    override init(rule: TodoFilterRule?) {
        if let rule = rule, rule.isValid {
            self.showClearButton = true
        } else {
            self.showClearButton = false
        }
        
        super.init(rule: rule)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Edit Filter")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        if showClearButton {
            navigationItem.rightBarButtonItem = clearBarButtonItem
        }
        
        setupActionsBar(actions: [doneAction])
    }
    
    @objc private func clickClear() {
        TPImpactFeedback.impactWithSoftStyle()
        dismiss(animated: true, completion: nil)
        didClickClear?()
    }
}
