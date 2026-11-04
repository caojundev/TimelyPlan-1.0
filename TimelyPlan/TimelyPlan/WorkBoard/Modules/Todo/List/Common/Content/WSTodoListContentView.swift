//
//  WSTodoListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办清单内容视图，各尺寸列表与网格共用。
///
/// 顶部标题、行列布局、卡片外观与数据绑定由基类提供，这里只负责清单行的创建与交互。
class WSTodoListContentView: WSTodoRowsContentView {
    
    init(itemCount: Int, layout: LayoutConfiguration = .list) {
        super.init(titleConfiguration: TitleConfiguration(iconName: "todo_list_24",
                                                          color: .primary,
                                                          title: resGetString("Todo Lists")),
                   layoutConfiguration: layout,
                   itemCount: itemCount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSTodoListRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        guard let rowView = rowView as? WSTodoListRowView else {
            return
        }
        
        /// 行本身响应点击
        rowView.didSelectListHandler = { [weak self] dataItem in
            self?.performAction(with: dataItem)
        }
    }
}
