//
//  WSTodoTagContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办标签内容视图，各尺寸列表与网格共用。
///
/// 顶部标题、行列布局、卡片外观与数据绑定由基类提供，这里只负责标签行的创建与交互。
class WSTodoTagContentView: WSTodoRowsContentView {
    
    init(itemCount: Int, layout: LayoutConfiguration = .list) {
        super.init(titleConfiguration: TitleConfiguration(iconName: "todo_task_tag_24",
                                                          color: Color(0xFF9F0A),
                                                          title: resGetString("Todo Tags")),
                   layoutConfiguration: layout,
                   itemCount: itemCount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSTodoTagRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        guard let rowView = rowView as? WSTodoTagRowView else {
            return
        }
        
        /// 行本身响应点击
        rowView.didSelectTagHandler = { [weak self] dataItem in
            self?.performAction(with: dataItem)
        }
    }
}
