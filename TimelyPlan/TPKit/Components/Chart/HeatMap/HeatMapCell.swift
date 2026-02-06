//
//  HeatMapCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/30.
//

import Foundation
import UIKit

class HeatMapCell: TPCollectionCell {
    
    /// 颜色视图
    let colorView: UIView = UIView()
    
    /// 颜色
    var color: UIColor? = Color(0x888888, 0.1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.frame = bounds
        colorView.layer.cornerRadius = cellStyle?.cornerRadius ?? 4.0
        colorView.layer.backgroundColor = color?.cgColor
    }
}
