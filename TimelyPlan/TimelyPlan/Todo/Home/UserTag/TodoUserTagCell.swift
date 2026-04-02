//
//  TodoUserTagCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/29.
//

import Foundation

protocol TodoUserTagCellDelegate: AnyObject {
    
    /// 点击更多
    func todoTagEditCellDidClickMore(_ cell: TodoUserTagCell)
}

class TodoUserTagCell: TPColorInfoTextValueTableCell {
    
    var userTag: TodoTag? {
        didSet {
            infoView.title = userTag?.name ?? resGetString("Untitled")

            let colorConfig = TPColorAccessoryConfig()
            colorConfig.color = userTag?.color ?? TodoTag.defaultColor
            self.colorConfig = colorConfig
            self.valueConfig = .valueText("3")
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
        rightView = moreButton
        rightViewSize = .mini
    }
    
    // MARK: - Event Response
    /// 点击更多
    func clickMore() {
        if let delegate = delegate as? TodoUserTagCellDelegate {
            delegate.todoTagEditCellDidClickMore(self)
        }
    }
    
}
