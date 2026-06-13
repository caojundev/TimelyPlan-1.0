//
//  CalendarEventInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/1.
//

import Foundation
import UIKit

class CalendarEventInfoView: TPInfoView {
    
    var color: UIColor? {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    /// 划线颜色
    var strikethroughColor: UIColor {
        get {
            return nameLabel.strikethroughColor
        }
        
        set {
            nameLabel.strikethroughColor = newValue
        }
    }
    
    private let colorViewSize = CGSize(width: 6.0, height: 36.0)
    private let colorViewMargins = UIEdgeInsets(right: 16.0)
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = colorViewSize.width / 2.0
        return view
    }()
    
    /// 名称标签
    private lazy var nameLabel: TPStrikethroughLabel = {
        let label = TPStrikethroughLabel()
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override func setupSubviews() {
        self.titleLabel = nameLabel /// 替换标题标签
        super.setupSubviews()
        
        leftAccessoryView = colorView
        leftAccessorySize = colorViewSize
        leftAccessoryMargins = colorViewMargins
    }
    
    func setCompleted(_ isCompleted: Bool,
                      animated: Bool = false,
                      completion: (() -> Void)? = nil) {
        guard nameLabel.isStrikethrough != isCompleted else {
            completion?()
            return
        }
        
        nameLabel.setStrikethrough(isCompleted, animated: animated, completion: completion)
        self.setNeedsLayout()
    }
}
