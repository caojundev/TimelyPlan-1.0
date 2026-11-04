//
//  WSTodoFilterContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办过滤器内容视图，各尺寸列表与网格共用。
///
/// 顶部标题、行列布局、卡片外观与数据绑定由基类提供，这里只负责过滤器行的创建与交互。
class WSTodoFilterContentView: WSTodoRowsContentView {
    
    /// 标题配色。取紫色梯度中较淡的一档，比首页的紫色更柔和
    private static let titleColor = UIColor.purple(3)
    
    init(itemCount: Int, layout: LayoutConfiguration = .list) {
        super.init(titleConfiguration: TitleConfiguration(iconName: "todo_home_filter_24",
                                                          color: WSTodoFilterContentView.titleColor,
                                                          title: resGetString("Todo Filters")),
                   layoutConfiguration: layout,
                   itemCount: itemCount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSTodoFilterRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        guard let rowView = rowView as? WSTodoFilterRowView else {
            return
        }
        
        /// 行本身响应点击
        rowView.didSelectFilterHandler = { [weak self] dataItem in
            self?.performAction(with: dataItem)
        }
    }
}
