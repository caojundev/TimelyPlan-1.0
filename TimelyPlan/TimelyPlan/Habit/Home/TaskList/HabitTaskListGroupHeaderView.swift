//
//  HabitTaskListGroupHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitTaskListGroupHeaderView: TPCollectionHeaderFooterView {
    
    var group: HabitTaskGroup? {
        didSet {
            updateInfo()
        }
    }
    
    /// 值标签
    private(set) lazy var valueLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        label.textAlignment = .center
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .systemBackground
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.infoView.imageConfig.margins = UIEdgeInsets(right: 5.0)
        self.contentView.addSubview(self.valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentLayoutFrame = contentView.layoutFrame()
        valueLabel.sizeToFit()
        valueLabel.right = contentLayoutFrame.maxX
        valueLabel.centerY = contentLayoutFrame.midY
        valueLabel.layer.cornerRadius = valueLabel.halfHeight
        valueLabel.layer.backgroundColor = infoView.titleConfig.textColor?.cgColor
        infoView.width = valueLabel.left - infoView.left
    }
    
    func updateInfo() {
        infoView.imageContent = .withName(group?.iconName)
        infoView.title = group?.name
        valueLabel.text = "\(group?.tasks?.count ?? 0)"
        setNeedsLayout()
    }
}
