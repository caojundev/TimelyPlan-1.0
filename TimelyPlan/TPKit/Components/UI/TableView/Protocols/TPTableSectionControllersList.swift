//
//  TPTableSectionControllersList.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation

protocol TPTableSectionControllersList: TPTableViewAdapterDataSource,
                                        TPTableViewAdapterDelegate {
    
    /// 返回列表区块控制器数组
    var sectionControllers: [TPTableBaseSectionController]? {get set}
}

extension TPTableSectionControllersList {
   
    // MARK: - TPTableViewAdapterDataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return sectionControllers
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let sectionController = sectionObject as? TPTableBaseSectionController
        sectionController?.adapter = adapter /// 设置adapter
        return sectionController?.items
    }
    
    // MARK: - TPTableListDelegate
    func adapter(_ adapter: TPTableViewAdapter, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.shouldHighlightRow(at: indexPath.row)
    }

    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.classForCell(at: indexPath.row)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.heightForRow(at: indexPath.row)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.didDequeCell(cell, forRowAt: indexPath.row)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        sectionController.didSelectRow(at: indexPath.row)
    }
    
    // MARK: - Header
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.heightForHeader()
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.classForHeader()
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.didDequeHeader(headerView)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, updateHeaderInSection section: Int) {
        if let headerView = adapter.headerView(in: section) {
            let sectionController = sectionController(for: adapter, inSection: section)
            return sectionController.didDequeHeader(headerView)
        }
    }
    
    // MARK: - Footer
    func adapter(_ adapter: TPTableViewAdapter, heightForFooterInSection section: Int) -> CGFloat {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.heightForFooter()
    }

    func adapter(_ adapter: TPTableViewAdapter, classForFooterInSection section: Int) -> AnyClass? {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.classForFooter()
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeFooter footerView: UITableViewHeaderFooterView, inSection section: Int) {
        let sectionController = sectionController(for: adapter, inSection: section)
        return sectionController.didDequeFooter(footerView)
    }

    func adapter(_ adapter: TPTableViewAdapter, updateFooterInSection section: Int) {
        if let footerView = adapter.footerView(in: section) {
            let sectionController = sectionController(for: adapter, inSection: section)
            return sectionController.didDequeFooter(footerView)
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.editingStyleForRow(at: indexPath.row)
    }
    
    // MARK: - SwipeActionsConfiguration
    func adapter(_ adapter: TPTableViewAdapter, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.leadingSwipeActionsConfigurationForRow(at: indexPath.row)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.trailingSwipeActionsConfigurationForRow(at: indexPath.row)
    }
    
    // MARK: - Checkmark
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        let sectionController = sectionController(for: adapter, inSection: indexPath.section)
        return sectionController.shouldShowCheckmarkForRow(at: indexPath.row)
    }
    
    // MARK: - Helpers
    private func sectionController(for adapter: TPTableViewAdapter,  inSection section: Int) -> TPTableBaseSectionController {
        let controller = adapter.object(at: section) as! TPTableBaseSectionController
        controller.section = section
        return controller
    }
}
