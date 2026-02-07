//
//  StatsSummaryDefaultCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/23.
//

import Foundation

class StatsSummaryCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as? StatsSummaryCellItem
            let summary = cellItem?.summary
            titleLabel.text = summary?.title
            
            if let attributedValue = summary?.attributedValue {
                valueLabel.attributed.text = attributedValue
            } else {
                valueLabel.text = summary?.value
            }
            
            setNeedsLayout()
        }
    }
    
    lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.font = BOLD_SYSTEM_FONT
        label.textColor = resGetColor(.title).withAlphaComponent(0.8)
        return label
    }()
    
    lazy var valueLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.font = UIFont.boldSystemFont(ofSize: 26.0)
        label.textColor = .primary
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        let titleHeight = 0.3 * layoutFrame.height
        titleLabel.width = layoutFrame.width
        titleLabel.height = titleHeight
        titleLabel.left = layoutFrame.minX
        titleLabel.top = layoutFrame.minY
        
        valueLabel.width = layoutFrame.width
        valueLabel.height = layoutFrame.height - titleHeight
        valueLabel.left = layoutFrame.minX
        valueLabel.top = titleLabel.bottom
    }
}

