//
//  TodoTaskCheckTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/13.
//

import Foundation

protocol TodoTaskCheckTableCellDelegate: AnyObject {
    
    /// 点击复选框
    func todoTaskCheckTableCellDidClickCheckbox(_ cell: TodoTaskCheckTableCell)
}

class TodoTaskCheckTableCell: TodoTaskBaseTableCell {

    /// 复选框
    var checkbox: TodoTaskCheckbox {
        return checkInfoView.checkbox
    }
    
    /// 复选信息视图
    private lazy var checkInfoView: TodoTaskCheckInfoView = {
        let view = TodoTaskCheckInfoView()
        view.didClickCheckbox = { [weak self] _ in
            self?.clickCheckbox()
        }
        
        return view
    }()
    
    override func setupContentSubviews() {
        self.infoView = checkInfoView
        super.setupContentSubviews()
    }
    
    override func reloadData(animated: Bool) {
        super.reloadData(animated: animated)
        
        if let layout = layout {
            let task = layout.task
            checkInfoView.checkbox.isEnabled = !task.isRemoved
            checkInfoView.leftViewMargins = layout.config.checkboxMargins
            checkInfoView.leftViewSize = layout.config.checkboxConfig.size
            checkInfoView.checkbox.config = layout.config.checkboxConfig
            checkInfoView.setNeedsLayout()
        }
        
        setNeedsLayout()
    }

    func clickCheckbox() {
        if let delegate = delegate as? TodoTaskCheckTableCellDelegate {
            delegate.todoTaskCheckTableCellDidClickCheckbox(self)
        }
        
        /// 更新完成状态
        updateCompleted(animated: true)
    }
}
