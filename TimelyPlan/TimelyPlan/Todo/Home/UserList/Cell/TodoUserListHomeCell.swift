//
//  TodoUserListHomeCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/30.
//

import Foundation
import UIKit

protocol TodoUserListHomeCellDelegate: TPExpandDefaultInfoTableCellDelegate {
    
    /// 点击更多
    func TodoUserListHomeCellDidClickMore(_ cell: TodoUserListHomeCell)
}

class TodoUserListHomeCell: TodoUserListBaseCell {

    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = moreButton
        self.rightViewSize = .mini
    }
    
    override func didChangeExpandedStatus() {
        updateSubtitle()
    }
    
    // MARK: - Update
    override func updateListInfo() {
        super.updateListInfo()
        updateSubtitle()
        updateTaskCount()
        updateExpanded()
        setNeedsLayout()
    }
    
    func updateExpanded(animated: Bool = false) {
        guard let list = self.list else {
            return
        }
        
        self.setExpanded(list.isExpanded, animated: animated)
    }
    
    /// 更新任务数目
    func updateTaskCount() {
        iconInfoTextValueView.valueConfig = .valueText("0")
    }
    
    func updateSubtitle() {
        guard let list = list else {
            infoView.subtitle = nil
            return
        }

        if isExpanded {
            infoView.subtitle = nil
        } else {
            let sublistCount = list.allSubItemsCount
            guard sublistCount > 0 else {
                infoView.subtitle = nil
                return
            }
            
            var format: String
            if sublistCount > 1 {
                format = resGetString("%ld sublists")
            } else {
                format = resGetString("%ld sublist")
            }
            
            infoView.subtitle = String(format: format, sublistCount)
        }
    }
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? TodoUserListHomeCellDelegate {
            delegate.TodoUserListHomeCellDidClickMore(self)
        }
    }
}
