//
//  HabitHomeWeekDayCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/7.
//

import Foundation
import UIKit

class HabitHomeWeekDayCell: HabitTaskStatusDayCell {
    // MARK: - Constants
    
    private let symbolLabelTopMargin = 0.0
    private let symbolLabelHeight = 30.0
    
    // MARK: - Properties
    
    /// 顶部符号标签
    lazy var symbolLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.font = UIFont.boldSystemFont(ofSize: 10.0)
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        symbolLabel.textColor = Color(0xf1f1f1)
        symbolLabel.alpha = 0.6
        contentView.addSubview(symbolLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSymbolLabel()
    }
    
    /// 布局符号标签
    private func layoutSymbolLabel() {
        let layoutFrame = layoutFrame()
        
        symbolLabel.width = layoutFrame.width
        symbolLabel.height = symbolLabelHeight
        symbolLabel.left = layoutFrame.minX
        symbolLabel.top = symbolLabelTopMargin
    }
    
    // MARK: - Frame Calculation
    
    override func statusProgressFrame() -> CGRect {
        let frame = contentView.layoutFrame()
        let x = frame.minX + (frame.width - statusProgressSize.width) / 2.0
        let y = frame.minY + symbolLabelTopMargin + symbolLabelHeight
        return CGRect(x: x, y: y, size: statusProgressSize)
    }
    
    override func updateDateInfo() {
        super.updateDateInfo()
        self.symbolLabel.text = date?.shortWeekdaySymbol()
    }
}
