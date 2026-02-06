//
// FocusTimerStepCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/23.
//

import Foundation
import UIKit

class FocusTimerStepCellItem: TPDefaultInfoTableCellItem {

    /// 步骤对象
    let step: FocusTimerStep
    
    init(step: FocusTimerStep) {
        self.step = step
        super.init()
        self.identifier = step.identifier ?? UUID().uuidString
        self.registerClass = FocusTimerStepCell.self
        self.height = 60.0
        self.contentPadding = UIEdgeInsets(top: 5.0,
                                           left: 16.0,
                                           bottom: 5.0,
                                           right: 10.0)
        self.leftViewSize = CGSize(width: 8.0, height: 32.0)
        self.leftViewMargins = UIEdgeInsets(right: 10.0)
        self.rightViewSize = .mini
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? FocusTimerStepCellItem else {
            return false
        }
        
        return step == object.step
    }
}

protocol FocusTimerStepCellDelegate: AnyObject {
    
    /// 点击更多按钮
    func focusTimerStepCellDidClickMore(_ cell: FocusTimerStepCell)
}

class FocusTimerStepCell: TPDefaultInfoTableCell {
    
    var step: FocusTimerStep?
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    private let colorView = UIView()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! FocusTimerStepCellItem
            let step = cellItem.step
            self.step = step
            self.colorView.backgroundColor = step.color
            self.title = step.name ?? resGetString("Untitled")
            self.subtitle = step.attributedInfo
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.leftView = colorView
        self.rightView = moreButton
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = leftViewSize.roundCornerRadius
        moreButton.imageConfig.color = resGetColor(.title)
    }
    
    @objc func clickMore(_ button: TPDefaultButton) {
        if let delegate = self.delegate as? FocusTimerStepCellDelegate {
            delegate.focusTimerStepCellDidClickMore(self)
        }
    }
}
