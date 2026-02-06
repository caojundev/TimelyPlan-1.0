//
//  TPSwitchTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/29.
//

import Foundation

class TPSwitchTableCellItem: TPImageInfoTableCellItem {
    
    /// 是否开启
    var isOn: Bool = false

    /// 数值改变回调
    var valueChanged: ((Bool) -> Void)?
    
    /// 开关按钮尺寸
    var switchButtonSize: CGSize {
        let switchButton = UISwitch()
        let size = switchButton.sizeThatFits(.unlimited)
        return size
    }
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TPSwitchTableCell.self
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout()
        layout.rightViewSize = switchButtonSize
        return layout
    }
}

protocol TPSwitchTableCellDelegate: AnyObject {
    
    /// 开关值改变
    func switchTableCellValueChanged(_ cell: TPSwitchTableCell)
}

class TPSwitchTableCell: TPImageInfoTableCell {

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPSwitchTableCellItem else {
                return
            }
            
            switchButton.isOn = cellItem.isOn
            rightViewSize = cellItem.switchButtonSize
        }
    }
    
    private(set) lazy var switchButton: UISwitch = {
        let button = UISwitch()
        button.sizeToFit()
        button.addTarget(self, action: #selector(valueDidChanged), for: .valueChanged)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        rightView = switchButton
        rightViewSize = switchButton.sizeThatFits(.unlimited)
    }

    @objc private func valueDidChanged(_ switchButton: UISwitch) {
        if let delegate = delegate as? TPSwitchTableCellDelegate {
            delegate.switchTableCellValueChanged(self)
        }
        
        if let cellItem = cellItem as? TPSwitchTableCellItem {
            cellItem.isOn = switchButton.isOn
            cellItem.valueChanged?(switchButton.isOn)
        }
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        switchButton.onTintColor = style?.tintColor
    }
}

