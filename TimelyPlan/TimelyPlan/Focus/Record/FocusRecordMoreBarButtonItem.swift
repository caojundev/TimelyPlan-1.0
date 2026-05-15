//
//  FocusRecordMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/20.
//

import Foundation
import UIKit

enum FocusRecordMoreMenuType: Int, TPMenuRepresentable {
    case addRecord  /// 添加记录
    case showDetail /// 显示详情
    case orderAscending  /// 升序
    case orderDescending /// 降序
    
    static func titles() -> [String] {
        return ["Add Record",
                "Show Detail",
                "Ascending",
                "Descending"]
    }
    
    var iconName: String? {
        switch self {
        case .addRecord:
            return "focus_record_add_24"
        case .showDetail:
            return "focus_record_showDetail_24"
        case .orderAscending:
            return "sort_order_ascending_24"
        case .orderDescending:
            return "sort_order_descending_24"
        }
    }
}

class FocusRecordMoreBarButtonItem: UIBarButtonItem {
    
    var sortOrder: TPSortOrder {
        get {
            return button.sortOrder
        }
        
        set {
            button.sortOrder = newValue
        }
    }
    
    var mode: FocusRecordListMode {
        get {
            return button.mode
        }
        
        set {
            button.mode = newValue
        }
    }
    
    /// 选中菜单类型
    var didSelectType: ((FocusRecordMoreMenuType) -> Void)?
    
    private let button = FocusRecordMoreButton()
    
    override init() {
        super.init()
        button.didSelectMenuAction = {[weak self] action in
            guard let type: FocusRecordMoreMenuType = action.actionType() else {
                return
            }
            
            self?.didSelectType?(type)
        }
        
        self.customView = button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class FocusRecordMoreButton: TPMenuListButton {
    
    var sortOrder = FocusState.shared.recordListOrder
    
    var mode = FocusState.shared.recordListMode
    
    override var menuItems: [TPMenuItem]? {
        get {
            let typeLists: [Array<FocusRecordMoreMenuType>] = [
                [.addRecord],
                [.showDetail],
                [.orderAscending,
                 .orderDescending]
            ]
            
            let showDetail = mode == .detail
            let order = self.sortOrder
            let items = TPMenuItem.items(with: typeLists) { type, action in
                action.handleBeforeDismiss = type != .addRecord
                switch type {
                case .showDetail:
                    action.isChecked = showDetail
                case .orderAscending:
                    action.isChecked = order == .ascending
                case .orderDescending:
                    action.isChecked = order == .descending
                default:
                    break
                }
            }
            
            return items
        }
        
        set {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 5.0)
        self.image = resGetImage("ellipsis_24")
        self.imageConfig.color = resGetColor(.title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
