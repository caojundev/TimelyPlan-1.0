//
//  HabitUserUnitSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation
import UIKit

class HabitUserUnitSectionController: HabitSystemUnitSectionController, HabitUserUnitCellDelegate {
    
    var userUnits: [String]
    
    override var items: [ListDiffable]? {
        return userUnits as [NSString]
    }
    
    override init() {
        self.userUnits = HabitSetting.shared.customUnits
        super.init()
        self.cellPadding = UIEdgeInsets(left: 12.0, right: 8.0)
        self.maxItemWidth = 128.0
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return UIEdgeInsets(horizontal: 8.0, vertical: 4.0)
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitUserUnitCell.self
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let unit = unit(at: index)
        var width = unit.width(with: titleConfig.font)
        width += cellPadding.horizontalLength + HabitUserUnitCell.deleteButtonSize.width
        width = clampedValue(width, minItemWidth, maxItemWidth)
        return CGSize(width: width, height: itemHeight)
    }
    
    override func unit(at index: Int) -> String {
        return userUnits[index]
    }
    
    func createNewUnit() {
        let title = resGetString("New Unit")
        let vc = TPTextFieldAlertController(title: title) { newUnit in
            guard let newUnit = newUnit else {
                return
            }
            
            self.didEndEditingUnit(newUnit)
            self.adapter?.performUpdate { _ in
                self.adapter?.scrollToItem(newUnit as NSString,
                                          at: .centeredVertically,
                                          animated: true) { _ in
                    self.adapter?.commitFocusAnimation(for: newUnit as NSString)
                }
            }
        }
        
        vc.selectAllAtBeginning = false
        vc.textField.textAlignment = .center
        vc.textField.font = BOLD_SYSTEM_FONT
        vc.show()
    }
    
    private func didEndEditingUnit(_ unit: String) {
        if userUnits.contains(unit) {
            return
        }
        
        userUnits.insert(unit, at: 0)
        saveUserUnits()
    }
    
    /// 保存自定义单位
    func saveUserUnits() {
        HabitSetting.shared.customUnits = userUnits
    }
    
    // MARK: - HabitUserUnitCellDelegate
    func userUnitCellDidClickDelete(_ cell: HabitUserUnitCell) {
        guard let indexPath = adapter?.indexPath(for: cell) else {
            return
        }
        
        userUnits.remove(at: indexPath.item)
        adapter?.performUpdate()
        saveUserUnits()
    }
}

extension HabitUserUnitSectionController: TPCollectionDragExchangeReorderDelegate {
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder, canMoveItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        return fromIndexPath.section == toIndexPath.section
    }
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, willBeginAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
    }
    
    func collectionDragReorderDidEnd(_ reorder: TPCollectionDragReorder) {
        saveUserUnits()
    }

    func collectionDragExchangeReorder(_ reorder: TPCollectionDragExchangeReorder, moveItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        TPImpactFeedback.impactWithSoftStyle()
        userUnits.moveObject(fromIndex: fromIndexPath.item, toIndex: toIndexPath.item)
        return true
    }
}
