//
//  CalendarScheduleDragAddView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/17.
//

import Foundation

class CalendarScheduleDragAddView: ScheduleDragView {
 
    // 文本 Label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = resGetString("New Task")
        label.textColor = .systemBlue
        label.font = .boldSystemFont(ofSize: 13.0)
        label.textAlignment = .center
        return label
    }()
    
    override func setupView() {
        super.setupView()
        titleLabel.frame = bounds
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    } 
}
