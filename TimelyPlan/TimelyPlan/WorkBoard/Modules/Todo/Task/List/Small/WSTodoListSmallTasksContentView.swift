//
//  WSTodoListSmallTasksContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办·小·自选清单任务列表的内容视图。
///
/// 头部展示所选清单的图标、名称与未完成任务数目，下方逐行展示未完成任务，
/// 超出展示条数时最后一行让给更多入口。
class WSTodoListSmallTasksContentView: WSIconInfoTextValueContentView {
    
    /// 未完成任务列表
    private let listView: WSTodoTaskMoreRowListView
    
    init(maximumRowCount: Int) {
        self.listView = WSTodoTaskMoreRowListView(maximumRowCount: maximumRowCount)
        super.init(frame: .zero)
        
        addSubview(listView)
        
        listView.didSelectTaskHandler = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
        listView.didClickCheckboxHandler = { [weak self] dataItem in
            (self?.interactor as? WSTodoTaskContentInteractor)?.clickCheckbox(for: dataItem)
        }
        listView.didSelectMoreHandler = { [weak self] in
            (self?.interactor as? WSTodoListTasksContentInteractor)?.selectMore()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 数据
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let dataItem = dataItem as? WSTodoListTasksDataItem
        updateHeader(title: dataItem?.listItem.title,
                     icon: dataItem?.listItem.icon,
                     iconBackColor: dataItem?.listItem.color ?? .primary,
                     count: dataItem?.taskCount ?? 0)
        listView.update(items: dataItem?.items ?? [])
    }
    
    // MARK: - 布局
    override func layoutContent(in frame: CGRect) {
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }
        
        listView.frame = frame
    }
}
