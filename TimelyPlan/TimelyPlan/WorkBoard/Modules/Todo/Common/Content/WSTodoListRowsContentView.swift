//
//  WSTodoListRowsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 行内容视图基类

/// 待办清单行内容视图基类，各尺寸列表与网格共用。
///
/// 统一顶部标题、行视图创建、点击转发与数据绑定；子类只负责行列数与行外观。
class WSTodoListRowsContentView: WSRowListView {
    
    /// 标题尺寸
    private enum Metrics {
        
        /// 标题图标边长及其与标题的间距
        static let iconSize: CGFloat = 16.0
        static let iconTitleSpacing: CGFloat = 6.0
        
        /// 标题高度及其与行列表的间距
        static let titleHeight: CGFloat = 18.0
        static let titleSpacing: CGFloat = 4.0
        
        /// 标题字号
        static let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .medium)
    }
    
    /// 内容与组件边缘的间距。标题固定占据顶部，行区域相应下移
    var contentPadding: UIEdgeInsets = .zero {
        didSet {
            padding = UIEdgeInsets(top: contentPadding.top + Metrics.titleHeight + Metrics.titleSpacing,
                                   left: contentPadding.left,
                                   bottom: contentPadding.bottom,
                                   right: contentPadding.right)
            setNeedsLayout()
        }
    }
    
    /// 图标 + 标题
    private lazy var titleView: TPIconTitleView = {
        let view = TPIconTitleView()
        view.icon = TPIcon(name: "todo_list_24")
        view.foreColor = .primary
        view.accessorySize = CGSize(value: Metrics.iconSize)
        view.accessoryMargins = UIEdgeInsets(right: Metrics.iconTitleSpacing)
        view.titleConfig = .withFont(Metrics.titleFont, textColor: .primary)
        view.title = resGetString("Todo Lists")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = bounds.inset(by: contentPadding)
        guard contentFrame.width > 0.0, contentFrame.height > 0.0 else {
            return
        }
        
        /// 行视图晚于标题创建，标题需要保持在最上层
        bringSubviewToFront(titleView)
        titleView.frame = CGRect(x: contentFrame.minX,
                                 y: contentFrame.minY,
                                 width: contentFrame.width,
                                 height: Metrics.titleHeight)
    }
    
    // MARK: - 行视图
    override func makeRowView(at index: Int) -> WSRowView {
        return WSTodoListRowView()
    }
    
    override func didAddRowView(_ rowView: WSRowView, at index: Int) {
        guard let rowView = rowView as? WSTodoListRowView else {
            return
        }
        
        /// 行本身响应点击
        rowView.didSelectListHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSTodoListRowsDataItem)?.items ?? []
        for (index, rowView) in rowViews.enumerated() {
            /// 空位传 nil，行视图内部会切换为骨架展示
            (rowView as? WSTodoListRowView)?.update(with: items[safe: index])
        }
    }
}
