//
//  HabitUserUnitCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/1.
//

import Foundation
import UIKit

protocol HabitUserUnitCellDelegate: AnyObject {
    
    /// 点击删除
    func userUnitCellDidClickDelete(_ cell: HabitUserUnitCell)
}

class HabitUserUnitCell: HabitUnitCell {
    
    static let deleteButtonSize = CGSize.size(5)
    
    /// 删除按钮
    private lazy var deleteButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("xmark_12")
        button.imageSize = .size(3)
        button.padding = .zero
        button.addTarget(self, action: #selector(clickDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(deleteButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        deleteButton.size = Self.deleteButtonSize
        deleteButton.right = layoutFrame.maxX
        deleteButton.centerY = layoutFrame.midY
        titleLabel.width = deleteButton.left - layoutFrame.minX
    }
    
    @objc func clickDelete(_ button: UIButton){
        if let delegate = self.delegate as? HabitUserUnitCellDelegate {
            delegate.userUnitCellDidClickDelete(self)
        }
    }
}


