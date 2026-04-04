//
//  TodoQuickAddProgressValueCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/28.
//

import Foundation
import UIKit

class TodoQuickAddProgressValueCellItem: TPBaseTableCellItem {
    
    var imageName: String?
    
    var title: String?
    
    /// 数值0～100
    var value: Int64 = 0
    
    var minValue: Int64 = 0
    
    var maxValue: Int64 = 100
    
    /// 数值是否为负数
    var isNegativeValue: Bool = false
    
    /// 是否显示正负符号
    var shouldShowSign: Bool = false
    
    /// 数值变化回调
    var valueChanged: ((Int64) -> Void)?
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TodoQuickAddProgressValueCell.self
        self.contentPadding = UIEdgeInsets(horizontal: 8.0, vertical: 8.0)
        self.height = 80.0
    }
}

class TodoQuickAddProgressValueCell: TPBaseTableCell {
    
    /// 数值变化回调
    var valueChanged: ((Int64) -> Void)?

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! TodoQuickAddProgressValueCellItem
            self.infoView.title = cellItem.title
            self.infoView.imageContent = .withName(cellItem.imageName)
            self.valueChanged = cellItem.valueChanged
            self.slider.fromValue = CGFloat(cellItem.minValue)
            self.slider.toValue = CGFloat(cellItem.maxValue)
            self.slider.setCurrentValue(CGFloat(cellItem.value))
            self.updateValueText()
        }
    }
    
    let slider = TodoProgressSlider()
    
    /// 标题标签
    let infoView = TPImageInfoTextValueView()
    
    override func setupContentSubviews() {
        infoView.padding = UIEdgeInsets(right: 8.0)
        infoView.imageConfig.margins = UIEdgeInsets(left: 4.0, right: 4.0)
        infoView.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        contentView.addSubview(infoView)
        contentView.addSubview(slider)
        slider.valueChanged = { [weak self] value in
            self?.didChangeValue(Int64(value))
        }
    }
    
    func didChangeValue(_ value: Int64) {
        let cellItem = cellItem as! TodoQuickAddProgressValueCellItem
        cellItem.value = clampedValue(value, cellItem.minValue, cellItem.maxValue)
        self.updateValueText()
        self.valueChanged?(value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        let sliderHeight = 36.0
        infoView.width = layoutFrame.width
        infoView.height = 20.0
        infoView.origin = layoutFrame.origin
        
        slider.width = layoutFrame.width
        slider.height = sliderHeight
        slider.bottom = layoutFrame.maxY
        slider.left = layoutFrame.minX
    }
    
    func updateValueText() {
        let cellItem = cellItem as! TodoQuickAddProgressValueCellItem
        let value = clampedValue(cellItem.value, cellItem.minValue, cellItem.maxValue)
        var valueText = "\(value)"
        if cellItem.shouldShowSign {
            let signText = cellItem.isNegativeValue ? "-" : "+"
            valueText = signText + valueText
        }
        
        self.infoView.valueConfig = .valueText(valueText)
    }
}
