//
//  TaskScheduleEditInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/8.
//

import Foundation
import UIKit

class TaskScheduleEditInfoView: UIView {

    var didClickDate: (() -> Void)?
    
    var schedule: TaskSchedule? {
        didSet {
            let isOverdue = schedule?.dateInfo?.isOverdue ?? false
            dateButton.titleConfig.textColor = isOverdue ? overdueColor : normalColor
            dateButton.title = schedule?.attributedInfo(isSlashFormattedDate: false,
                                                        normalColor: normalColor,
                                                        highlightedColor: normalColor,
                                                        overdueColor: overdueColor,
                                                        badgeBaselineOffset: 6.0,
                                                        badgeFont: UIFont.boldSystemFont(ofSize: 8.0),
                                                        imageSize: .size(4),
                                                        showRepeatCount: true,
                                                        separator: " • ")
            setNeedsLayout()
        }
    }
    
    private let normalColor: UIColor = .primary
    private let overdueColor: UIColor = .redPrimary
    
    private lazy var dateButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textColor = .primary
        button.normalBackgroundColor = .clear
        button.selectedBackgroundColor = .clear
        button.addTarget(self,
                         action: #selector(clickDate(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        addSubview(self.dateButton)
        self.addSeparator(position: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateButton.frame = layoutFrame()
    }
    
    @objc private func clickDate(_ button: UIButton) {
        didClickDate?()
    }
}
