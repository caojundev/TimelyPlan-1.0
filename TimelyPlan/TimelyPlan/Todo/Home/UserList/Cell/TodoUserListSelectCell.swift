//
//  TodoUserListSelectCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/10.
//

import Foundation
import UIKit

class TodoUserListSelectCell: TodoUserListBaseCell {
    
    /// 对勾图标
    private lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.size = .mini
        view.image = resGetImage("checkmark_24")
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = checkmarkView
        rightViewSize = .mini
        isChecked = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkView.updateImage(withColor: tintColor)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkView.isHidden = !checked
    }
}
