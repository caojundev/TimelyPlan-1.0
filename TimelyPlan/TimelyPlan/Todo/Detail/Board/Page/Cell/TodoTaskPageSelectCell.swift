//
//  TodoTaskPageSelectCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/14.
//

import Foundation
import UIKit

class TodoTaskPageSelectCell: TodoTaskPageBaseCell {
    
    lazy var selectInfoView: TodoTaskSelectInfoView = {
        let view = TodoTaskSelectInfoView()
        return view
    }()
    
    override func setupContentSubviews() {
        self.infoView = selectInfoView
        super.setupContentSubviews()
    }
    
    override func reloadData(animated: Bool) {
        super.reloadData(animated: animated)
        if let layout = layout {
            selectInfoView.leftViewSize = layout.config.checkboxConfig.size
            selectInfoView.leftViewMargins = layout.config.checkboxMargins
            selectInfoView.setNeedsLayout()
        }
        
        setNeedsLayout()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        selectInfoView.setSelected(checked, animated: animated)
    }
}
