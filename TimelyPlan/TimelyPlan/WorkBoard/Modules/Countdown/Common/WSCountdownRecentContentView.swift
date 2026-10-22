//
//  WSCountdownRecentContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 倒数日「最近」类组件的展示条数。
///
/// 中号与大号组件唯一的差异是展示条数：中号 3 条、大号 5 条。
/// 交互器取数与内容视图行数共用这里的常量，避免两处分别硬编码。
enum WSCountdownRecentItemCount {
    
    /// 中号组件的展示条数
    static let medium = 3
    
    /// 大号组件的展示条数
    static let large = 5
}

// MARK: - 内容视图

/// 倒数日「最近」内容视图。
///
/// 纵向排列若干行倒数日事项，每行由 `WSCountdownEventRowView` 渲染，
/// 视觉与倒数日列表单元格一致。行数由初始化时传入，供中号、大号组件按尺寸复用。
class WSCountdownRecentContentView: WSPluginContentView {
    
    /// 行视图，按展示顺序排列
    private var rowViews: [WSCountdownEventRowView] = []
    
    /// 初始化内容视图
    /// - Parameter itemCount: 行数，与交互器最多展示的事项数目保持一致
    init(itemCount: Int) {
        super.init(frame: .zero)
        
        rowViews = (0..<max(itemCount, 0)).map { _ in
            let rowView = WSCountdownEventRowView()
            /// 行内点击直接交给交互器处理
            rowView.didSelectHandler = { [weak self] dataItem in
                self?.interactor?.performAction(with: dataItem)
            }
            
            addSubview(rowView)
            return rowView
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = bounds
        let rowCount = CGFloat(rowViews.count)
        guard layoutFrame.height > 0.0, rowCount > 0.0 else {
            return
        }
        
        let rowHeight = layoutFrame.height / rowCount
        for (index, rowView) in rowViews.enumerated() where !rowView.isHidden {
            rowView.frame = CGRect(x: layoutFrame.minX,
                                   y: layoutFrame.minY + CGFloat(index) * rowHeight,
                                   width: layoutFrame.width,
                                   height: rowHeight)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        /// 按顺序展示事项，超出行数的部分忽略，不足的行展示占位横条
        let dataItems = (dataItem as? WSCountdownRecentDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            rowView.update(with: dataItems[safe: index])
        }
        
        setNeedsLayout()
    }
}
