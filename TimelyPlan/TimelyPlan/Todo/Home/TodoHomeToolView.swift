//
//  TodoHomeToolView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/29.
//

import Foundation
import UIKit

class TodoHomeToolView: TPToolbar {
    
    /// 点击统计
    var didClickStatistic: (() -> Void)?

    /// 点击添加
    var didClickAdd: (() -> Void)?
    
    lazy var statButtonItem: TPBarButtonItem = {
        let image = resGetImage("chart_bar_24")
        let item = TPBarButtonItem(image: image) {[weak self] _ in
            TPImpactFeedback.impactWithSoftStyle()
            self?.didClickStatistic?()
        }
        
        return item
    }()
    
    lazy var addButtonItem: TPBarButtonItem = {
        let image = resGetImage("plus_24")
        let item = TPBarButtonItem(image: image) {[weak self] _ in
            TPImpactFeedback.impactWithSoftStyle()
            self?.didClickAdd?()
        }
        
        return item
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.buttonItems = [statButtonItem,
                            .flexibleSpaceButtonItem,
                            addButtonItem]
        self.addSeparator(position: .top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
