//
//  HabitUserUnitSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation
import UIKit

class HabitUserUnitSectionController: HabitSystemUnitSectionController, HabitUserUnitCellDelegate {
    
    var userUnits = ["Count", "Cup", "Page", "m", "km", "ml", "L", "Line"]
    
    override var items: [ListDiffable]? {
        return userUnits as [NSString]
    }
    
    override init() {
        super.init()
        self.cellAccessorySize = HabitUserUnitCell.deleteButtonSize
        self.cellPadding = UIEdgeInsets(left: 12.0)
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return HabitUserUnitCell.self
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
    }
    
    // MARK: - HabitUserUnitCellDelegate
    func userUnitCellDidClickDelete(_ cell: HabitUserUnitCell) {
        guard let indexPath = adapter?.indexPath(for: cell) else {
            return
        }
        
        userUnits.remove(at: indexPath.item)
        adapter?.performUpdate()
    }
}

protocol HabitUserUnitCellDelegate: AnyObject {
    
    /// 点击删除
    func userUnitCellDidClickDelete(_ cell: HabitUserUnitCell)
}

class HabitUserUnitCell: HabitUnitCell {
    
    static let deleteButtonSize = CGSize.size(5)
    
    /// 删除按钮
    private lazy var deleteButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("xmark_12")
        button.imageSize = .size(3)
        button.padding = .zero
        button.addTarget(self, action: #selector(clickDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(deleteButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        deleteButton.size = Self.deleteButtonSize
        deleteButton.right = layoutFrame.maxX
        deleteButton.centerY = layoutFrame.midY
        titleLabel.width = deleteButton.left - layoutFrame.minX
        
        deleteButton.normalBackgroundColor = .random
        titleLabel.backgroundColor = .random
    }
    
    @objc func clickDelete(_ button: UIButton){
        if let delegate = self.delegate as? HabitUserUnitCellDelegate {
            delegate.userUnitCellDidClickDelete(self)
        }
    }
}

