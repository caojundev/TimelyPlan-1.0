//
//  HabitSystemUnitSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

class HabitSystemUnitSectionController: TPCollectionBaseSectionController {
    
    var cellPadding = UIEdgeInsets(horizontal: 12.0)
    
    /// 单元格配件尺寸
    var cellAccessorySize: CGSize = .zero
    
    /// 条目最小宽度
    var minItemMinWidth = 55.0
    
    /// 条目高度
    var itemHeight = 36.0
    
    lazy var titleConfig: TPLabelConfig = {
        let config = TPLabelConfig()
        config.textAlignment = .center
        return config
    }()
    
    private lazy var units: [String] = {
        let units = ["Count", "Cup", "Page", "m", "km", "ml", "L", "Line"]
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
        guard let adapter = adapter else {
            return .zero
        }
        
        let collectionSize = adapter.collectionViewSize()
        let sectionInset = sectionInset()
        let contentWidth = collectionSize.width - sectionInset.horizontalLength
        let maxItemWidth = contentWidth - 2 * interitemSpacing()
    
        let unit = unit(at: index)
        var width = unit.width(with: titleConfig.font)
        width += cellPadding.horizontalLength + cellAccessorySize.width
        width = clampedValue(width, minItemMinWidth, maxItemWidth)
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
