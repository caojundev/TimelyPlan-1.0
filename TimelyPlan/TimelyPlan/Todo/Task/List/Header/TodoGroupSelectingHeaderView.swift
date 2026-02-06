//
//  TodoGroupNormalHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/15.
//

import Foundation

protocol TodoGroupSelectingHeaderViewDelegate: TodoGroupBaseHeaderViewDelegate {
    
    /// 点击全选
    func selectingHeaderViewDidClickSelectAll(_ headerView: TodoGroupSelectingHeaderView)
    
    /// 点击反选
    func selectingHeaderViewDidClickDeselectAll(_ headerView: TodoGroupSelectingHeaderView)
}

class TodoGroupSelectingHeaderView: TodoGroupBaseHeaderView {
    
    /// 数目信息
    var countInfo: (selectedCount: Int, totalCount: Int) = (0, 0) {
        didSet {
            updateCountInfo()
        }
    }
    
    lazy var selectButton: TodoGroupSelectButton = {
        let button = TodoGroupSelectButton()
        button.addTarget(self,
                         action: #selector(clickSelect(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubViews() {
        super.setupContentSubViews()
        contentView.addSubview(selectButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        selectButton.sizeToFit()
        selectButton.right = layoutFrame.maxX
        selectButton.centerY = layoutFrame.midY
        let expandButtonMaxWidth = selectButton.left - layoutFrame.minX - 5.0
        if expandButton.width > expandButtonMaxWidth {
            expandButton.width = expandButtonMaxWidth
        }
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
        
        let delegate = delegate as? TodoGroupSelectingHeaderViewDelegate
        if countInfo.selectedCount == countInfo.totalCount {
            delegate?.selectingHeaderViewDidClickDeselectAll(self)
        } else {
            delegate?.selectingHeaderViewDidClickSelectAll(self)
        }
    }
    
}
