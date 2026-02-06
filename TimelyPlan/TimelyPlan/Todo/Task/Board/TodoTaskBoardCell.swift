//
//  TodoTaskBoardCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation
import UIKit

class TodoTaskBoardCell: UICollectionViewCell {
    
    /// 看板单页卡片视图
    private(set) lazy var pageView: TodoTaskPageView = {
        let cardView = TodoTaskPageView(frame: bounds)
        return cardView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(pageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pageView.frame = bounds
    }
}
