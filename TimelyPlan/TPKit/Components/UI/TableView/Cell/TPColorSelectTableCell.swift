//
//  TPColorSelectTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/31.
//

import Foundation
import UIKit

class TPColorSelectTableCellItem: TPBaseTableCellItem {
    
    /// 当前图标
    var selectedColor: UIColor?
    
    /// 可供选择的颜色数组
    var colors: [UIColor]?
    
    /// 选中图标回调
    var didSelectColor: ((UIColor) -> Void)?
    
    /// 圆点尺寸
    var circleSize = CGSize(40.0, 40.0)
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = TPColorSelectTableCell.self
        height = 80.0
    }
}

class TPColorSelectTableCell: TPBaseTableCell {

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! TPColorSelectTableCellItem
            if let colors = cellItem.colors, colors.count > 0 {
                colorSelectView.colors = colors
            }
            
            colorSelectView.itemSize = cellItem.circleSize
            colorSelectView.selectedColor = cellItem.selectedColor
            colorSelectView.reloadData()
        }
    }
    
    /// 颜色选择视图
    private(set) var colorSelectView: TPColorSelectView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        colorSelectView = TPColorSelectView()
        colorSelectView.didSelectColor = { [weak self] color in
            self?.didSelectColor(color)
        }
        
        contentView.addSubview(colorSelectView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorSelectView.frame = bounds
    }
    
    private func didSelectColor(_ color: UIColor) {
        let cellItem = cellItem as! TPColorSelectTableCellItem
        cellItem.didSelectColor?(color)
    }
    
    /// 滚动到可视位置
    func scrollToSelectedColor(animated: Bool = true) {
        colorSelectView.scrollToSelectedColor(animated: animated)
    }
}
