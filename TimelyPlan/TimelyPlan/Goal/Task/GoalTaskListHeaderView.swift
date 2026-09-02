//
//  GoalTaskListHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation
import UIKit

/// 目标任务列表区块头视图
class GoalTaskListHeaderView: UICollectionReusableView {
    
    /// 标题
    var title: TextRepresentable? {
        get {
            return infoView.title
        }
        
        set {
            infoView.title = newValue
        }
    }
    
    /// 信息视图
    private let infoView = TPInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        infoView.frame = layoutFrame
    }
}
