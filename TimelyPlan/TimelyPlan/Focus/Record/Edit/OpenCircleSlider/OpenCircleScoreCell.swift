//
//  OpenCircleScoreCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/28.
//

import Foundation

class OpenCircleScoreCellItem: TPBaseTableCellItem {
    
    /// 评分（0～100）
    var score: Int = 0
    
    /// 选中评分回调
    var didSelectScore: ((Int) -> Void)?
    
    /// 底部文本
    var footerText: String? = resGetString("Tap or drag the slider to rate")
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = OpenCircleScoreCell.self
        height = 340.0
    }
}

class OpenCircleScoreCell: TPBaseTableCell {
    
    var didSelectScore: ((Int) -> Void)?
    
    /// 脚文本标签
    let footerLabel = TPLabel()

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! OpenCircleScoreCellItem
            self.didSelectScore = cellItem.didSelectScore
            self.slider.value = CGFloat(cellItem.score)
            self.footerLabel.text = cellItem.footerText
        }
    }
    
    private var slider: OpenCircleAdjustSlider!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        slider = OpenCircleAdjustSlider()
        slider.valueChanged = { [weak self] value in
            if let cellItem = self?.cellItem as? OpenCircleScoreCellItem {
                cellItem.score = value
            }
            
            self?.didSelectScore?(value)
        }
        
        contentView.addSubview(slider)
        
        footerLabel.numberOfLines = 0
        footerLabel.font = SMALL_SYSTEM_FONT
        footerLabel.textAlignment = .center
        addSubview(footerLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds.inset(by: UIEdgeInsets(bottom: 15.0))
        footerLabel.textColor = UIColor.label.withAlphaComponent(0.4)
        footerLabel.width = layoutFrame.width
        footerLabel.sizeToFit()
        footerLabel.bottom = layoutFrame.maxY
        footerLabel.alignHorizontalCenter()
        
        slider.width = layoutFrame.width
        slider.height = footerLabel.top - layoutFrame.minY
        slider.top = layoutFrame.minY
        slider.left = layoutFrame.minX
    }
}
