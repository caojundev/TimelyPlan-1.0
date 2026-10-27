//
//  WSHabitDayContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 天容器视图

/// 天容器视图。
///
/// 按天数等分排列天进度视图，天数由数据决定（周视图 7 天）
/// 点击时按横坐标定位到具体的一天并回调。
class WSHabitDayContainerView: UIView {
    
    /// 每天的数据
    var dayItems: [WSHabitDayDataItem] = [] {
        didSet {
            reloadDayViews()
        }
    }
    
    /// 点击某一天的回调
    var didSelectDayHandler: ((WSHabitDayDataItem) -> Void)?
    
    /// 每天对应的视图
    private var dayViews: [WSHabitDayProgressView] = []
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickDay(_:)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !dayItems.isEmpty, bounds.width > 0.0 else {
            return
        }
        
        let itemWidth = bounds.width / CGFloat(dayItems.count)
        for (index, dayView) in dayViews.enumerated() where index < dayItems.count {
            dayView.frame = CGRect(x: CGFloat(index) * itemWidth,
                                   y: 0.0,
                                   width: itemWidth,
                                   height: bounds.height)
        }
    }
    
    // MARK: - 交互
    @objc private func clickDay(_ gesture: UITapGestureRecognizer) {
        guard !dayItems.isEmpty, bounds.width > 0.0 else {
            return
        }
        
        let itemWidth = bounds.width / CGFloat(dayItems.count)
        let location = gesture.location(in: self)
        let index = min(max(Int(location.x / itemWidth), 0), dayItems.count - 1)
        if let dayItem = dayItems[safe: index], !dayItem.isFuture {
            didSelectDayHandler?(dayItem)
        }
    }
    
    // MARK: - 子视图
    /// 按数据量补齐或隐藏天视图
    private func reloadDayViews() {
        while dayViews.count < dayItems.count {
            let dayView = WSHabitDayProgressView()
            dayViews.append(dayView)
            addSubview(dayView)
        }
        
        for (index, dayView) in dayViews.enumerated() {
            let item = dayItems[safe: index]
            dayView.isHidden = (item == nil)
            dayView.dayItem = item
        }
        
        setNeedsLayout()
    }
}
