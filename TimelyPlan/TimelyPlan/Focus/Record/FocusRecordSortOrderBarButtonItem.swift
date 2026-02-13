//
//  FocusRecordOrderBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/12.
//

import Foundation
import UIKit

enum FocusRecordSortOrder: Int, TPMenuRepresentable, Codable {
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

class FocusRecordSortOrderBarButtonItem: UIBarButtonItem {
    
    /// 选中菜单类型
    var didSelectType: ((FocusRecordSortOrder) -> Void)?
    
    var sortOrder: FocusRecordSortOrder {
        get {
            return orderButton.sortOrder
        }
        
        set {
            orderButton.sortOrder = newValue
        }
    }
    
    private let orderButton = FocusRecordOrderButton()
    
    override init() {
        super.init()
        orderButton.didSelectMenuAction = {[weak self] action in
            guard let selectSortOrder: FocusRecordSortOrder = action.actionType() else {
                return
            }
            
            self?.sortOrder = selectSortOrder
            self?.didSelectType?(selectSortOrder)
        }
        
        self.customView = orderButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class FocusRecordOrderButton: TPMenuListButton {
    
    var sortOrder: FocusRecordSortOrder = .ascending {
        didSet {
            self.image = sortOrder.iconImage
        }
    }
    
    override var menuItems: [TPMenuItem]? {
        get {
            let item = TPMenuItem.item(with: FocusRecordSortOrder.allCases) { type, menuAction in
                menuAction.handleBeforeDismiss = true
                menuAction.isChecked = type == self.sortOrder
            }
            
            return [item]
        }

        set {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 5.0)
        self.imageConfig.color = resGetColor(.title)
        self.image = sortOrder.iconImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
