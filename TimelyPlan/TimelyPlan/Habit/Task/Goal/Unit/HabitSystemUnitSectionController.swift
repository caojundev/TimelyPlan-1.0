//
//  HabitSystemUnitSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

class HabitSystemUnitSectionController: TPCollectionBaseSectionController {
    
    var cellPadding = UIEdgeInsets(horizontal: 12.0)
    
    /// 条目最小宽度
    var minItemWidth = 60.0
    
    /// 条目最大宽度
    var maxItemWidth = 60.0
    
    /// 条目高度
    var itemHeight = 36.0
    
    lazy var titleConfig: TPLabelConfig = {
        let config = TPLabelConfig()
        config.textAlignment = .center
        return config
    }()
    
    private lazy var units: [String] = {
        let units: [String] = [
            "times",           // 次
            "minutes",         // 分钟
            "hours",           // 小时
            "kilometers",      // 公里
            "meters",          // 米
            "pages",           // 页
            "books",           // 本
            "chapters",        // 章
            "glasses",         // 杯
            "pieces",          // 个
            "sets",            // 组
            "steps",           // 步
            "calories",        // 千卡
            "kilograms",       // 公斤
            "grams",           // 克
            "items",           // 件
            "tasks",           // 项
            "days",            // 天
            "words",           // 词
            "percent"          // %
        ]
        
        var localizedUnits = [String]()
        for unit in units {
            let localizedUnit: String = resGetString(unit)
            localizedUnits.append(localizedUnit)
        }
        
        return localizedUnits
    }()
    
    override var items: [ListDiffable]? {
        return units as [NSString]
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitUnitCell.self
    }

    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        guard let cell = cell as? HabitUnitCell else {
            return
        }
        
        cell.padding = cellPadding
        cell.titleConfig = titleConfig
        cell.titleLabel.text = unit(at: index)
    }
 
    override func sizeForItem(at index: Int) -> CGSize {
        let unit = unit(at: index)
        var width = unit.width(with: titleConfig.font)
        width += cellPadding.horizontalLength
        width = clampedValue(width, minItemWidth, maxItemWidth)
        return CGSize(width: width, height: itemHeight)
    }

    func unit(at index: Int) -> String {
        return units[index]
    }
}

class HabitUnitCell: TPCollectionCell {

    var titleConfig = TPLabelConfig() {
        didSet {
            updateTitleConfig()
            setNeedsLayout()
        }
    }
    
    let titleLabel = UILabel()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(titleLabel)
        updateTitleConfig()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = layoutFrame()
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        titleLabel.textAlignment = titleConfig.textAlignment
        if isHighlighted || isChecked {
            titleLabel.textColor = titleConfig.highlightedTextColor ?? titleConfig.textColor
        } else {
            titleLabel.textColor = titleConfig.textColor
        }
    }
    
    private func updateTitleConfig() {
        titleLabel.textAlignment = titleConfig.textAlignment
        titleLabel.font = titleConfig.font
    }
}
