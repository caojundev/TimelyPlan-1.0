//
//  HabitTaskListBaseCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

class HabitTaskListBaseCell: TPCollectionCell {
    
    var task: HabitTask? {
        didSet {
            updateTaskInfo()
        }
    }
    
    /// 遮罩视图
    private let coverView = UIView()
    
    /// 阴影视图
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.layer.shadowColor = Color(0x000000, 0.2).cgColor
        view.layer.shadowOffset = CGSize(width:0, height: 4.0)
        view.layer.shadowRadius = 4.0
        view.layer.shadowOpacity = 0.6
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        insertSubview(shadowView, belowSubview: contentView)
        contentView.padding = UIEdgeInsets(left: 16.0, right: 16.0)
        contentView.addSubview(coverView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let radius = contentView.layer.cornerRadius
        shadowView.frame = bounds
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                                   cornerRadius: radius).cgPath
        
        coverView.frame = bounds
        coverView.layer.cornerRadius = radius
        coverView.layer.backgroundColor = Color(0x000000, 0.1).cgColor
    }
    
    func updateStyleWithColor(_ color: UIColor) {
        contentView.backgroundColor = color.withBrightness(0.5)
    }
    
    /// 更新任务信息
    func updateTaskInfo() {
        guard let task = task else {
            return
        }
        
        updateStyleWithColor(task.color)
    }
}


