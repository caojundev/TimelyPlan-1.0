//
//  WSTodoListSingleSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 单选列表

/// 待办清单单选列表。
///
/// 与多选列表一致只展示用户创建的清单（不含收件箱），点击切换选中状态；
/// 再次点击已选清单可取消选择。
class WSTodoListSingleSelectionViewController: TodoBaseListSelectViewController {
    
    /// 选择变化回调，取消选择时返回 nil
    var didChangeSelection: ((String?) -> Void)?
    
    /// 已选清单标识
    private(set) var selectedIdentifier: String?
    
    init(selectedIdentifier: String?) {
        self.selectedIdentifier = selectedIdentifier
        super.init(list: nil, allowMaxDepth: Int.max)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterSelection()
    }
    
    /// 只展示用户创建的清单，不包含收件箱区块
    override func setupSectionControllers() {
        self.sectionControllers = [self.userSectionController]
    }
    
    // MARK: - 选中
    /// 已删除的清单不再保留在选中状态
    private func filterSelection() {
        guard let identifier = selectedIdentifier else {
            return
        }
        
        let lists = (userSectionController.items ?? []).compactMap { $0 as? TodoList }
        guard !lists.isEmpty,
              !lists.contains(where: { $0.identifier == identifier }) else {
            return
        }
        
        selectedIdentifier = nil
        adapter.updateCheckmarks()
        didChangeSelection?(nil)
    }
    
    // MARK: - TPTableSectionControllerDelegate
    override func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                         didSelectRowAt index: Int) {
        guard sectionController == userSectionController,
              let list = userSectionController.item(at: index) as? TodoList else {
            return
        }
        
        selectedIdentifier = selectedIdentifier == list.identifier ? nil : list.identifier
        TPImpactFeedback.impactWithSoftStyle()
        adapter.updateCheckmarks()
        didChangeSelection?(selectedIdentifier)
    }
    
    override func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                         shouldShowCheckmarkForRowAt index: Int) -> Bool {
        guard sectionController == userSectionController,
              let list = userSectionController.item(at: index) as? TodoList else {
            return false
        }
        
        return list.identifier == selectedIdentifier
    }
}
