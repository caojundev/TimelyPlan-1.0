//
//  TodoTaskPageSelectingHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit

protocol TodoTaskPageSelectingHeaderViewDelegate: TodoTaskPageSectionHeaderViewDelegate {
    
    /// 点击全选
    func taskPageSelectHeaderViewDidClickSelectAll(_ headerView: TodoTaskPageSelectingHeaderView)
    
    /// 点击反选
    func taskPageSelectHeaderViewDidClickDeselectAll(_ headerView: TodoTaskPageSelectingHeaderView)
}

class TodoTaskPageSelectingHeaderView: TodoTaskPageSectionHeaderView {
    
    /// 数目信息
    var countInfo: (selectedCount: Int, totalCount: Int) = (0, 0) {
        didSet {
            updateCountInfo()
        }
    }
    
    lazy var selectButton: TodoGroupSelectingButton = {
        let button = TodoGroupSelectingButton()
        button.addTarget(self,
                         action: #selector(clickSelect(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(selectButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        selectButton.sizeToFit()
        selectButton.right = layoutFrame.maxX
        selectButton.centerY = layoutFrame.midY
        
        infoView.width = selectButton.left - layoutFrame.minX
    }
    
    private func updateCountInfo() {
        if countInfo.totalCount >= countInfo.selectedCount {
            selectButton.title = "\(countInfo.selectedCount)/\(countInfo.totalCount)"
        } else {
            selectButton.title = "0"
        }

        if countInfo.selectedCount == countInfo.totalCount {
            selectButton.setChecked(true, animated: false)
        } else {
            selectButton.setChecked(false, animated: false)
        }
        
        setNeedsLayout()
    }
    
    // MARK: - Event Response
    /// 点击选择按钮
    @objc func clickSelect(_ button: UIButton) {
        guard countInfo.totalCount > 0 else {
            return
        }
        
        let delegate = delegate as? TodoTaskPageSelectingHeaderViewDelegate
        if countInfo.selectedCount == countInfo.totalCount {
            delegate?.taskPageSelectHeaderViewDidClickDeselectAll(self)
        } else {
            delegate?.taskPageSelectHeaderViewDidClickSelectAll(self)
        }
    }
}
