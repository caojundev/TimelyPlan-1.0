//
//  WSCountdownPluginContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 倒数日组件数据。由倒数日内容 ViewModel 取数后生成，交由内容视图渲染。
class WSCountdownDataItem: NSObject, WSPluginDataItem {
    
    let title: String
    
    init(title: String) {
        self.title = title
        super.init()
    }
}

// MARK: - 内容视图
class WSCountdownPluginContentView: WSPluginContentView {
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 15.0, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = bounds
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        guard let dataItem = dataItem as? WSCountdownDataItem else {
            showEmptyState()
            return
        }
        
        titleLabel.text = dataItem.title
    }
    
    private func showEmptyState() {
        titleLabel.isHidden = true
    }
}
