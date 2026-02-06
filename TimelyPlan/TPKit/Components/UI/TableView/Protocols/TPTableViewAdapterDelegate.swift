//
//  TPTableViewAdapterDelegate.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation

protocol TPTableViewAdapterDelegate: UIScrollViewDelegate {
    
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath)
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass?
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func adapter(_ adapter: TPTableViewAdapter, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool
    func adapter(_ adapter: TPTableViewAdapter, styleForRowAt indexPath: IndexPath) -> TPTableCellStyle?
    
    /// 通知更新区块索引处对应的头视图
    func adapter(_ adapter: TPTableViewAdapter, updateHeaderInSection section: Int)
    func adapter(_ adapter: TPTableViewAdapter, updateFooterInSection section: Int)
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass?
    func adapter(_ adapter: TPTableViewAdapter, heightForFooterInSection section: Int) -> CGFloat
    func adapter(_ adapter: TPTableViewAdapter, classForFooterInSection section: Int) -> AnyClass?
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int)
    func adapter(_ adapter: TPTableViewAdapter, didDequeFooter footerView: UITableViewHeaderFooterView, inSection section: Int)
    
    
    func adapter(_ adapter: TPTableViewAdapter, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    func adapter(_ adapter: TPTableViewAdapter, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    func adapter(_ adapter: TPTableViewAdapter, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    func adapter(_ adapter: TPTableViewAdapter, willBeginEditingRowAt indexPath: IndexPath)
    
    func adapter(_ adapter: TPTableViewAdapter, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    func adapter(_ adapter: TPTableViewAdapter, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
}

extension TPTableViewAdapterDelegate {
    
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func adapter(_ adapter: TPTableViewAdapter, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func adapter(_ adapter: TPTableViewAdapter, styleForRowAt indexPath: IndexPath) -> TPTableCellStyle? {
        return adapter.cellStyle
    }
    
    func adapter(_ adapter: TPTableViewAdapter, updateHeaderInSection section: Int) {
        
    }
    
    func adapter(_ adapter: TPTableViewAdapter, updateFooterInSection section: Int) {
        
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForFooterInSection section: Int) -> AnyClass? {
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeFooter footerView: UITableViewHeaderFooterView, inSection section: Int) {
        
    }
    
    func adapter(_ adapter: TPTableViewAdapter, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func adapter(_ adapter: TPTableViewAdapter, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, willBeginEditingRowAt indexPath: IndexPath) {
        
    }
    
    func adapter(_ adapter: TPTableViewAdapter, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func adapter(_ adapter: TPTableViewAdapter, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TPBaseTableCell {
            cell.willDisplay()
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TPBaseTableCell {
            cell.didEndDisplaying()
        }
    }
}
