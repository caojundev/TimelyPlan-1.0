//
//  TodoTaskPageSelectHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation

protocol TodoTaskPageSelectHeaderViewDelegate: TodoTaskPageNormalHeaderViewDelegate {
    
    /// 点击全选
    func taskPageSelectHeaderViewDidClickSelectAll(_ headerView: TodoTaskPageSelectHeaderView)
    
    /// 点击反选
    func taskPageSelectHeaderViewDidClickDeselectAll(_ headerView: TodoTaskPageSelectHeaderView)
}

class TodoTaskPageSelectHeaderView: TodoTaskPageNormalHeaderView {
    
    /// 数目信息
    var countInfo: (selectedCount: Int, totalCount: Int)? = (0, 0) {
        didSet {
            updateCountInfo()
        }
    }
    
    lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.innerColor = resGetColor(.title)
        checkbox.outerColor = checkbox.innerColor
        checkbox.outerLineWidth = 2
        checkbox.addTarget(self, action: #selector(clickSelect(_:)), for: .touchUpInside)
        return checkbox
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        infoView.leftAccessoryView = checkbox
        infoView.leftAccessorySize = .size(5)
        infoView.leftAccessoryMargins = UIEdgeInsets(left: 16.0, right: 10.0)
    }
    
    private func updateCountInfo() {
        guard let countInfo = countInfo else {
            infoView.valueConfig = nil
            checkbox.isChecked = false
            return
        }
        
        var valueText: String?
        if countInfo.totalCount >= countInfo.selectedCount {
            valueText = "\(countInfo.selectedCount)/\(countInfo.totalCount)"
        }
        
        infoView.valueConfig = .valueText(valueText)
        checkbox.isChecked = (countInfo.selectedCount == countInfo.totalCount)
    }
    
    // MARK: - Event Response
    /// 点击选择按钮
    @objc func clickSelect(_ button: UIButton) {
        guard let countInfo = countInfo, countInfo.totalCount > 0 else {
            return
        }
        
        let delegate = delegate as? TodoTaskPageSelectHeaderViewDelegate
        if countInfo.selectedCount == countInfo.totalCount {
            delegate?.taskPageSelectHeaderViewDidClickDeselectAll(self)
        } else {
            delegate?.taskPageSelectHeaderViewDidClickSelectAll(self)
        }
    }
}
