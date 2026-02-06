//
//  TPTableBaseSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation

protocol TPTableSectionControllerDelegate: AnyObject {
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int)
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool
}

extension TPTableSectionControllerDelegate {
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        return false
    }
}

class TPTableBaseSectionController: NSObject {

    /// 代理对象
    weak var delegate: TPTableSectionControllerDelegate?
    
    /// 适配器
    weak var adapter: TPTableViewAdapter?
    
    /// 当前区块索引
    var section: Int = 0
    
    /// 区块唯一标识
    lazy var identifier: String = {
        return UUID().uuidString
    }()

    /// 该区块所有条目
    var items: [ListDiffable]? {
        return nil
    }
    
    var currentItems: [ListDiffable] {
        return adapter?.items(for: self) ?? []
    }

    // MARK: - Cell
    func classForCell(at index: Int) -> AnyClass? {
        return UITableViewCell.self
    }
    
    func heightForRow(at index: Int) -> CGFloat {
        return 50.0
    }

    func shouldHighlightRow(at index: Int) -> Bool {
        return true
    }
    
    func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let bShow = delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index)
        return bShow ?? false
    }
    
    func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? TPBaseTableCell else {
            return
        }
        
        cell.delegate = self
        cell.style = styleForRow(at: index)
    }
    
    func didSelectRow(at index: Int) {
        delegate?.tableSectionController(self, didSelectRowAt: index)
    }
    
    // MARK: - Header
    func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    func classForHeader() -> AnyClass? {
        return UITableViewHeaderFooterView.self
    }
    
    func didDequeHeader(_ headerView: UITableViewHeaderFooterView) {
        
    }
    
    // MARK: - Footer
    func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    func classForFooter() -> AnyClass? {
        return TPBaseTableHeaderFooterView.self
    }
    
    func didDequeFooter(_ footerView: UITableViewHeaderFooterView) {
        
    }
    
    func editingStyleForRow(at index: Int) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // MARK: - SwipeActionsConfiguration
    func leadingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func trailingSwipeActionsConfigurationForRow(at index: Int) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    // MARK: - Style
    func styleForRow(at index: Int) -> TPTableCellStyle? {
        return adapter?.cellStyle
    }
    
    // MARK: - Helpers
    
    /// 获取当前区块特定索引处的条目
    func item(at index: Int) -> AnyObject? {
        if let items = adapter?.items(for: self), index < items.count {
            return items[index]
        }

        return nil
    }
    
    func cellForRow(at index: Int) -> UITableViewCell? {
        let indexPath = IndexPath(row: index, section: section)
        return adapter?.cellForRow(at: indexPath)
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? TPTableBaseSectionController {
            return self.identifier == object.identifier
        }
        
        return false
    }
    
    // MARK: - 弹窗显示
    enum PopoverPosition {
        case left
        case right
    }
    
    func popoverShow(_ viewController: UIViewController,
                     from cell: UITableViewCell,
                     position: PopoverPosition = .right) {
        let frame = cell.bounds.inset(by: UIEdgeInsets(value: 10.0))
        let sourceRect: CGRect
        let preferredPosition: TPPopoverPosition
        let permittedPositions: [TPPopoverPosition]
        if position == .right {
            sourceRect = CGRect(x: frame.maxX, y: frame.minY, width: 0.0, height: frame.height)
            preferredPosition = .bottomLeft
            permittedPositions = [.bottomLeft, .topLeft]
        } else {
            sourceRect = CGRect(x: frame.minX, y: frame.minY, width: 0.0, height: frame.height)
            preferredPosition = .bottomRight
            permittedPositions = [.bottomRight, .topRight]
        }
        
        viewController.popoverShow(from: cell,
                                   sourceRect: sourceRect,
                                   isSourceViewCovered: false,
                                   preferredPosition: preferredPosition,
                                   permittedPositions: permittedPositions,
                                   animated: true,
                                   completion: nil)
    }
}
