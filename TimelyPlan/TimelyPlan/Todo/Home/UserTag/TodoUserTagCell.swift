//
//  TodoUserTagCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/29.
//

import Foundation

protocol TodoUserTagCellDelegate: AnyObject {
    
    /// 点击更多
    func todoTagCellDidClickMore(_ cell: TodoUserTagCell)
    
    /// 获取单元格待办数量
    func todoTagCell(_ cell: TodoUserTagCell, requestCount completion: @escaping (Int?) -> Void)
}

class TodoUserTagCell: TPColorInfoTextValueTableCell {
    
    var userTag: TodoTag? {
        didSet {
            updateTagInfo()
        }
    }
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.didClickHandler = { [weak self] in
            self?.clickMore()
        }
        
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentPadding = UIEdgeInsets(left: 6.0, right: 12.0)
        self.rightView = moreButton
        self.rightViewSize = .mini
    }
    
    // MARK: - Update
    let colorSize = CGSize(width: 10.0, height: 10.0)
    
    func updateTagInfo() {
        let colorConfig = TPColorAccessoryConfig()
        colorConfig.size = colorSize
        colorConfig.color = userTag?.color ?? TodoTag.defaultColor
        self.colorConfig = colorConfig
        self.infoView.title = userTag?.name ?? resGetString("Untitled")
        self.updateTaskCount()
        setNeedsLayout()
    }
    
    /// 更新任务数目
    func updateTaskCount() {
        guard let userTag = self.userTag, let delegate = delegate as? TodoUserTagCellDelegate else {
            self.valueConfig = nil
            setNeedsLayout()
            return
        }
        
        let identifier = userTag.identifier
        delegate.todoTagCell(self) { [weak self] count in
            guard let self = self, identifier == self.userTag?.identifier else {
                return
            }
            
            if let count = count, count > 0 {
                self.valueConfig = .valueText("\(count)")
            } else {
                self.valueConfig = nil
            }
        }
        
        setNeedsLayout()
    }
    
    // MARK: - Event Response
    /// 点击更多
    func clickMore() {
        if let delegate = delegate as? TodoUserTagCellDelegate {
            delegate.todoTagCellDidClickMore(self)
        }
    }
    
}
