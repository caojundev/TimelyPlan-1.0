//
//  TodoTaskMoveUserListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/5.
//

import Foundation
import UIKit

protocol TodoTaskMoveUserListCellDelegate: AnyObject {
    
    func taskMoveUserListCell(_ cell: TodoTaskMoveUserListCell, didToggleSectionExpand isExpanded: Bool)
}

class TodoTaskMoveUserListCell: TodoUserListBaseCell {
    
    override var list: TodoList? {
        didSet {
            updateSectionExpandedButton()
        }
    }
    
    /// 板块展开展开按钮
    private(set) lazy var sectionExpandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = .zero
        button.image = resGetImage("todo_home_expand_18")
        button.imageConfig.color = .systemGray3
        button.hitTestEdgeInsets = UIEdgeInsets(value: -10.0)
        button.addTarget(self,
                         action: #selector(clickSectionExpand(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override var collapseOnExpandButtonDisabled: Bool {
        return false
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = sectionExpandButton
        rightViewSize = .mini
    }
    
    private func updateSectionExpandedButton() {
        guard let sections = list?.sections, sections.count > 0  else {
            sectionExpandButton.isHidden = true
            return
        }

        sectionExpandButton.isHidden = false
    }
    
    /// 点击展开或收起按钮
    @objc private func clickSectionExpand(_ button: UIButton) {
        let isExpanded = !sectionExpandButton.isExpanded
        setSectionExpanded(isExpanded, animated: true)
        if let delegate = self.delegate as? TodoTaskMoveUserListCellDelegate {
            delegate.taskMoveUserListCell(self, didToggleSectionExpand: isExpanded)
        }
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        if isChecked {
            titleConfig.textColor = .primary
        } else {
            titleConfig.textColor = resGetColor(.title)
        }
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        updateCellStyle()
        infoView.setNeedsLayout()
    }
    
    
    // MARK: - Public Methods
    /// 板块展开
    func setSectionExpanded(_ isExpanded: Bool, animated: Bool) {
        guard sectionExpandButton.isExpanded != isExpanded else {
            return
        }
        
        sectionExpandButton.setExpanded(isExpanded, animated: animated)
    }
}
