//
//  TodoFilterHomeCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation

protocol TodoFilterHomeCellDelegate: AnyObject {
    
    /// 点击更多
    func todoFilterHomeCellDidClickMore(_ cell: TodoFilterHomeCell)
}

class TodoFilterHomeCell: TPColorInfoTextValueTableCell {
    
    let colorSize = CGSize(width: 4.0, height: 16.0)
    var filter: TodoFilter? {
        didSet {
            infoView.title = filter?.name ?? resGetString("Untitled")
            let color = filter?.color ?? TodoFilter.defaultColor
            self.colorConfig = .withColor(color, size: colorSize)
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
        if let delegate = delegate as? TodoFilterHomeCellDelegate {
            delegate.todoFilterHomeCellDidClickMore(self)
        }
    }
    
}
