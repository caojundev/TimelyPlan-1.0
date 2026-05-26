//
//  TodoSearchHistoryClearFooterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/25.
//

import Foundation
import UIKit

class TodoSearchHistoryClearFooterItem: TPDefaultInfoTableHeaderFooterItem {
    
    var didClickClear: (() -> Void)?
    
    override init() {
        super.init()
        self.registerClass = TodoSearchHistoryClearFooterView.self
    }
}

class TodoSearchHistoryClearFooterView: TPDefaultInfoTableHeaderFooterView {
    
    var didClickClear: (() -> Void)?
    
    override var headerFooterItem: TPBaseTableHeaderFooterItem? {
        didSet {
            guard let headerFooterItem = headerFooterItem as? TodoSearchHistoryClearFooterItem else {
                return
            }
            
            didClickClear = headerFooterItem.didClickClear
        }
    }
    
    private lazy var clearButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.titleConfig.font = SYSTEM_FONT
        button.titleConfig.textColor = .secondaryLabel
        button.title = resGetString("Clear Search History")
        button.addTarget(self, action: #selector(clickClear(_:)), for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(clearButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clearButton.sizeToFit()
        clearButton.alignCenter()
    }
    
    @objc private func clickClear(_ button: UIButton) {
        didClickClear?()
    }
}
