//
//  WSTodoListMultiSelectionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 多选列表

/// 待办清单多选列表。
///
/// 展示用户创建的清单（不含收件箱），点击切换选中状态，超出上限的选择会被忽略；
/// 底部标签展示已选数量与上限，选择顺序即组件内的展示顺序。
class WSTodoListMultiSelectionViewController: TodoBaseListSelectViewController {
    
    /// 选择变化回调，按选择顺序返回清单标识
    var didChangeSelection: (([String]) -> Void)?
    
    /// 已选清单标识，保持选择顺序
    private(set) var selectedIdentifiers: [String]
    
    /// 最多可选择的清单数量
    private let maximumSelectionCount: Int
    
    /// 选中数量标签高度
    private let selectionCountLabelHeight: CGFloat = 36.0
    
    /// 选中数量标签
    private lazy var selectionCountLabel: TPLabel = {
        let label = TPLabel()
        label.font = .boldSystemFont(ofSize: 11.0)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = themeBackgroundColor
        label.edgeInsets = UIEdgeInsets(horizontal: 16.0, top: 4.0)
        return label
    }()
    
    init(selectedIdentifiers: [String], maximumSelectionCount: Int) {
        self.selectedIdentifiers = selectedIdentifiers
        self.maximumSelectionCount = max(maximumSelectionCount, 1)
        super.init(list: nil, allowMaxDepth: Int.max)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selectionCountLabel)
        selectionCountLabel.addSeparator(position: .top)
        
        filterSelection()
        updateSelectionCount()
    }
    
    /// 只展示用户创建的清单，不包含收件箱区块
    override func setupSectionControllers() {
        self.sectionControllers = [self.userSectionController]
    }
    
    /// 选中数量标签占用列表下方的高度
    override func tableViewFrame() -> CGRect {
        var frame = super.tableViewFrame()
        frame.size.height = max(frame.height - selectionCountLabelHeight, 0.0)
        return frame
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        selectionCountLabel.frame = CGRect(x: 0.0,
                                           y: wrapperView.bottom,
                                           width: view.width,
                                           height: selectionCountLabelHeight)
    }
    
    // MARK: - 选中数量
    /// 已删除的清单不再保留在选中列表内
    private func filterSelection() {
        let lists = (userSectionController.items ?? []).compactMap { $0 as? TodoList }
        let validIdentifiers = Set(lists.map { $0.identifier })
        guard !validIdentifiers.isEmpty else {
            return
        }
        
        let filteredIdentifiers = selectedIdentifiers.filter { validIdentifiers.contains($0) }
        guard filteredIdentifiers != selectedIdentifiers else {
            return
        }
        
        selectedIdentifiers = filteredIdentifiers
        didChangeSelection?(filteredIdentifiers)
    }
    
    /// 更新已选数量与上限提示
    private func updateSelectionCount() {
        let countText = String(format: resGetString("%ld selected"), selectedIdentifiers.count)
        let maximumText = String(format: resGetString("Up to %ld"), maximumSelectionCount)
        selectionCountLabel.text = "\(countText) · \(maximumText)"
    }
    
    // MARK: - TPTableSectionControllerDelegate
    override func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                         didSelectRowAt index: Int) {
        guard sectionController == userSectionController,
              let list = userSectionController.item(at: index) as? TodoList else {
            return
        }
        
        if let index = selectedIdentifiers.firstIndex(of: list.identifier) {
            selectedIdentifiers.remove(at: index)
            TPImpactFeedback.impactWithSoftStyle()
        } else {
            /// 超出上限时不再加入，给出重一点的反馈
            guard selectedIdentifiers.count < maximumSelectionCount else {
                TPImpactFeedback.impactWithRigidStyle()
                return
            }
            
            selectedIdentifiers.append(list.identifier)
            TPImpactFeedback.impactWithSoftStyle()
        }
        
        adapter.updateCheckmarks()
        updateSelectionCount()
        didChangeSelection?(selectedIdentifiers)
    }
    
    override func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                         shouldShowCheckmarkForRowAt index: Int) -> Bool {
        guard sectionController == userSectionController,
              let list = userSectionController.item(at: index) as? TodoList else {
            return false
        }
        
        return selectedIdentifiers.contains(list.identifier)
    }
}
