//
//  NameIconEditTableViewCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/26.
//

import Foundation

class HabitIconNameTableCellItem: TPTextFieldTableCellItem {
    
    /// 当前图标
    var icon: TPIcon?
    
    /// 选中图标回调
    var didSelectIcon: ((TPIcon) -> Void)?
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = HabitIconNameTableCell.self
        height = 140.0
    }
}

class HabitIconNameTableCell: TPTextFieldTableCell {
    
    let iconSize = CGSize(width: 60.0, height: 60.0)
    let iconTopMargin = 20.0
    let textFieldTopMargin = 10.0
    let textFieldHeight = 40.0
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! HabitIconNameTableCellItem
            iconView.icon = cellItem.icon
        }
    }
    
    /// 图标视图
    private lazy var iconView: TPIconView = {
        let iconView = TPIconView()
        iconView.placeholderCharacter = "C"
        iconView.backColor = Color(light: 0x252847, dark: 0xFFFFFF, alpha: 0.1)
        iconView.foreColor = Color(light: 0x000000, dark: 0xFFFFFF, alpha: 0.85)
        iconView.borderWidth = 1.0
        iconView.didClick = { [weak self] in
            TPImpactFeedback.impactWithSoftStyle()
            self?.editIcon()
        }
        
        return iconView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.size = iconSize
        iconView.cornerRadius = iconSize.height / 2.0
        iconView.top = iconTopMargin
        iconView.alignHorizontalCenter()
        textField.top = iconView.bottom + textFieldTopMargin
        textField.height = textFieldHeight
    }
    
    /// 编辑图标
    public func editIcon() {
        let vc = TPIconCharacterEditViewController()
        vc.text = iconView.icon?.text
        vc.didEndEditing = { text in
            self.didSelectIcon(TPIcon(text: text))
        }

        vc.showAsNavigationRoot()
    }
    
    func didSelectIcon(_ icon: TPIcon) {
        iconView.icon = icon
        if let cellItem = cellItem as? HabitIconNameTableCellItem {
            cellItem.didSelectIcon?(icon)
        }
    }
}
