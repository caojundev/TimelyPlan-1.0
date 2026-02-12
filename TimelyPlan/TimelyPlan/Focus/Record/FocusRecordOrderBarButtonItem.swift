//
//  FocusRecordOrderBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/12.
//

import Foundation
import UIKit

enum FocusRecordOrderType: Int, TPMenuRepresentable {
    case ascending = 0 /// 升序
    case descending    /// 降序
    
    var iconName: String? {
        switch self {
        case .ascending:
            return "focus_record_order_ascending_24"
        case .descending:
            return "focus_record_order_descending_24"
        }
    }
    
    static func titles() -> [String] {
        return ["Ascending", "Descending"]
    }
}

class FocusRecordOrderBarButtonItem: UIBarButtonItem {
    
    /// 选中菜单类型
    var didSelectType: ((FocusRecordOrderType) -> Void)?
    
    var orderType: FocusRecordOrderType {
        get {
            return orderButton.orderType
        }
        
        set {
            orderButton.orderType = newValue
        }
    }
    
    private let orderButton = FocusRecordOrderButton()
    
    override init() {
        super.init()
        orderButton.didSelectMenuAction = {[weak self] action in
            guard let selectOrderType: FocusRecordOrderType = action.actionType() else {
                return
            }
            
            self?.orderType = selectOrderType
            self?.didSelectType?(selectOrderType)
        }
        
        self.customView = orderButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class FocusRecordOrderButton: TPMenuListButton {
    
    var orderType: FocusRecordOrderType = .ascending {
        didSet {
            self.image = orderType.iconImage
        }
    }
    
    override var menuItems: [TPMenuItem]? {
        get {
            let item = TPMenuItem.item(with: FocusRecordOrderType.allCases) { type, menuAction in
                menuAction.handleBeforeDismiss = true
                menuAction.isChecked = type == self.orderType
            }
            
            return [item]
        }

        set {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 5.0)
        self.imageConfig.color = resGetColor(.title)
        self.image = orderType.iconImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
