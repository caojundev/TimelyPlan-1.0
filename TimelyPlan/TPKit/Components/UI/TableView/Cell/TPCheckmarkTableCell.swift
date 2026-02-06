//
//  TPCheckmarkTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/31.
//

import Foundation
import UIKit

class TPCheckmarkTableCellItem: TPImageInfoTableCellItem {
    
    override init() {
        super.init()
        self.registerClass = TPCheckmarkTableCell.self
        self.rightViewSize = .mini
    }
}

class TPCheckmarkTableCell: TPImageInfoTableCell {
    
    lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = checkmarkView
        self.rightViewSize = .mini
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
