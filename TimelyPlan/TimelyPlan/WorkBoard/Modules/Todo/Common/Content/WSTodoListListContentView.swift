//
//  WSTodoListListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 列表内容视图

/// 待办清单列表内容视图，各列表尺寸共用。
///
/// 顶部为图标 + 标题，其下纵向排列若干清单行，条数与交互器最多展示的数目保持一致；
/// 清单不足时，剩余的行展示骨架，与其它组件行的空位保持一致。
class WSTodoListListContentView: WSTodoListRowsContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 4.0)
        
        /// 行间距
        static let rowSpacing: CGFloat = 4.0
        
        /// 标题图标边长及其与标题的间距
        static let titleIconSize: CGFloat = 16.0
        static let titleIconMargins = UIEdgeInsets(left: 12.0, right: 8.0)
        
        /// 标题高度及其与行列表的间距
        static let titleHeight: CGFloat = 18.0
        static let titleSpacing: CGFloat = 4.0
        
        /// 标题字号
        static let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .medium)
    }
    
    /// 图标 + 标题
    private lazy var titleView: TPIconTitleView = {
        let view = TPIconTitleView()
        view.icon = TPIcon(name: "todo_list_24")
        view.foreColor = .primary
        view.accessorySize = CGSize(value: Metrics.titleIconSize)
        view.accessoryMargins = UIEdgeInsets(right: Metrics.titleIconMargins)
        view.titleConfig = .withFont(Metrics.titleFont, textColor: .primary)
        view.title = resGetString("Todo Lists")
        return view
    }()
    
    init(itemCount: Int) {
        super.init(frame: .zero)
        
        /// 顶部留出标题的位置，行列表在标题下方排布
        self.padding = UIEdgeInsets(top: Metrics.padding.top + Metrics.titleHeight + Metrics.titleSpacing,
                                    left: Metrics.padding.left,
                                    bottom: Metrics.padding.bottom,
                                    right: Metrics.padding.right)
        self.columnCount = 1
        self.rowCount = max(itemCount, 0)
        self.rowSpacing = Metrics.rowSpacing
        
        addSubview(titleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = bounds.inset(by: Metrics.padding)
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        titleView.frame = CGRect(x: contentFrame.minX,
                                 y: contentFrame.minY,
                                 width: contentFrame.width,
                                 height: Metrics.titleHeight)
    }
    
    // MARK: - 行视图
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        super.didAddRowView(rowView, at: index)
        
        /// 列表不展示卡片底色
        rowView.normalBackColor = .clear
    }
}
