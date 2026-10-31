//
//  WSQuadrantSmallTaskListContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 四象限·小·单个象限任务列表的内容视图。
///
/// 展示配置中选择的象限：头视图可进入象限详情、可快速添加任务，
/// 其下为未完成任务列表，任务超出上限时展示更多入口。
class WSQuadrantSmallTaskListContentView: WSPluginContentView {
    
    /// 象限任务列表，默认取布局中的第一个象限，数据到达后按配置更新
    private lazy var listView = WSQuadrantTaskListView(
        quadrant: QuadrantSetting.shared.layout.getQuadrants().first ?? .urgentImportant
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = .zero
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
