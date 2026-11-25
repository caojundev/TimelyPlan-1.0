//
//  WSQuadrantTaskListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·任务列表的内容视图，各尺寸共用。
///
/// 展示配置中选择的象限：头视图可进入象限详情、可快速添加任务，
/// 其下为未完成任务列表，任务超出上限时展示更多入口。
class WSQuadrantTaskListContentView: WSPluginContentView {
    
    /// 任务行的最小高度
    private let minimumRowHeight: CGFloat
    
    /// 任务行之间的间距
    private let rowSpacing: CGFloat
    
    /// 象限任务列表，默认取布局中的第一个象限，数据到达后按配置更新
    private lazy var listView = WSQuadrantTaskListView(
        quadrant: QuadrantSetting.shared.layout.getQuadrants().first ?? .urgentImportant,
        minimumRowHeight: minimumRowHeight,
        rowSpacing: rowSpacing
    )
    
    init(minimumRowHeight: CGFloat = 30.0, rowSpacing: CGFloat = 0.0) {
        self.minimumRowHeight = minimumRowHeight
        self.rowSpacing = rowSpacing
        super.init(frame: .zero)
        
        self.padding = .zero
        /// 列表铺满组件，圆角与底色由组件外框提供
        listView.layer.cornerRadius = 0.0
        
        listView.didSelectHeaderHandler = { [weak self] quadrant in
            self?.showDetail(for: quadrant)
        }
        listView.didClickAddHandler = { [weak self] quadrant in
            (self?.interactor as? WSQuadrantTasksContentInteractor)?.quickAddTask(for: quadrant, from: self)
        }
        listView.didSelectMoreHandler = { [weak self] quadrant in
            self?.showDetail(for: quadrant)
        }
        listView.didSelectTaskHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
        listView.didClickCheckboxHandler = { [weak self] dataItem in
            (self?.interactor as? WSQuadrantTasksContentInteractor)?.clickCheckbox(for: dataItem)
        }
        
        addSubview(listView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        listView.frame = layoutFrame()
    }
    
    /// 进入象限详情，与四象限主页面点击象限标题的行为一致
    private func showDetail(for quadrant: Quadrant) {
        WSQuadrantDetailPresenter.showDetail(for: quadrant, from: self)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let group = (dataItem as? WSQuadrantTasksDataItem)?.quadrants.first
        listView.update(with: group)
        setNeedsLayout()
    }
}
