//
//  TPColorSelectPopoverView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/21.
//

import Foundation
import UIKit

class TPColorSelectPopoverView: TPBasePopoverView {
    
    var didSelectColor: ((UIColor) -> Void)?
    
    var selectedColor: UIColor?

    var colors: [UIColor]?
    
    private let itemSize: CGSize = .mini
    
    /// 颜色选择视图
    private lazy var selectView: TPColorSelectView = {
        let view = TPColorSelectView()
        view.itemSize = itemSize
        view.indicatorBorderWidth = 2.0
        view.didSelectColor = { [weak self] color in
            self?.didSelectColor?(color)
            self?.hide(animated: true, completion: nil)
        }
        
        return view
    }()

    override func setupSubviews() {
        super.setupSubviews()
        self.contentView.padding = UIEdgeInsets(horizontal: 10.0, vertical: 5.0)
        self.popoverView = selectView
    }
    
    override var popoverContentSize: CGSize {
        return CGSize(width: 280.0, height: 60.0)
    }
    
    func reloadData() {
        if let colors = colors {
            selectView.colors = colors
        }
        
        selectView.selectedColor = selectedColor
        selectView.reloadData()
    }

    /// 滚动到可视位置
    func scrollToSelectedColor(animated: Bool = true) {
        selectView.scrollToSelectedColor(animated: animated)
    }
}
