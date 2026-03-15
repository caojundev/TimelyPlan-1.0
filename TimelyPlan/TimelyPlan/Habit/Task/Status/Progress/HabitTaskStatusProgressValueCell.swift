//
//  HabitTaskStatusProgressValueCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/16.
//

import Foundation
import UIKit

/// 习惯任务状态进度值单元格
class HabitTaskStatusProgressValueCell: HabitTaskStatusProgressCell {
    
    // MARK: - Constants
    
    private let valueLabelTopMargin = 5.0
    private let valueLabelHeight = 20.0
    
    /// 空白标签尺寸
    private let emptyValueLabelWidth = 25.0
    private let emptyValueLabelHeight = 5.0
    
    // MARK: - Properties
    
    var emptyLineColor: UIColor = Color(light: 0x121212, dark: 0xf1f1f1, alpha: 0.2) {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 值文本标签
    lazy var valueLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueLabelFrame = valueLabelFrame()
        let valueText = valueLabel.text ?? ""
        
        if valueText.isEmpty {
            setupEmptyValueLabel(in: valueLabelFrame)
        } else {
            setupValueLabel(with: valueText, in: valueLabelFrame)
        }
    }
    
    // MARK: - Frame Calculation
    
    /// 计算数值标签布局信息
    func valueLabelFrame() -> CGRect {
        let layoutFrame = contentView.layoutFrame()
        let statusProgressFrame = statusProgressFrame()
        return CGRect(x: layoutFrame.minX,
                      y: statusProgressFrame.maxY + valueLabelTopMargin,
                      width: layoutFrame.width,
                      height: valueLabelHeight)
    }
    
    // MARK: - Setup Methods
    
    /// 设置空白值标签样式
    private func setupEmptyValueLabel(in frame: CGRect) {
        valueLabel.width = emptyValueLabelWidth
        valueLabel.height = emptyValueLabelHeight
        valueLabel.center = frame.center
        
        valueLabel.layer.cornerRadius = emptyValueLabelHeight / 2.0
        valueLabel.layer.backgroundColor = emptyLineColor.cgColor
    }
    
    /// 设置值标签样式
    private func setupValueLabel(with text: String, in frame: CGRect) {
        valueLabel.layer.backgroundColor = nil
        valueLabel.layer.cornerRadius = 0.0
        valueLabel.frame = frame
    }
}
