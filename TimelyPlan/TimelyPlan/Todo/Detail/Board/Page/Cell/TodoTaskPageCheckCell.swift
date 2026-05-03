//
//  TodoTaskPageCheckCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/14.
//

import Foundation

protocol TodoTaskPageCheckCellDelegate: AnyObject {
    
    /// 点击复选框
    func todoTaskPageCheckCellDidClickCheckbox(_ cell: TodoTaskPageCheckCell)
}

class TodoTaskPageCheckCell: TodoTaskPageBaseCell {

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
            checkInfoView.leftViewSize = layout.config.checkboxConfig.size
            checkInfoView.leftViewMargins = layout.config.checkboxMargins
            let task = layout.task
            checkInfoView.checkbox.isEnabled = !task.isRemoved
            checkInfoView.checkbox.config = layout.config.checkboxConfig
            checkInfoView.setNeedsLayout()
        }
        
        setNeedsLayout()
    }

    func clickCheckbox() {
        if let delegate = delegate as? TodoTaskPageCheckCellDelegate {
            delegate.todoTaskPageCheckCellDidClickCheckbox(self)
        }
    }
}
