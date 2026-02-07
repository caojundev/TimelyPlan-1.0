//
//  FocusMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/22.
//

import Foundation
import UIKit

/// 更多菜单
enum FocusMoreMenuType: Int, TPMenuRepresentable {
    case allRecords /// 所有记录
    case addRecord  /// 添加记录
    case archived /// 已归档
    case settings /// 设置
    
    static func titles() -> [String] {
        return ["All Records",
                "Add Record",
                "Archived",
                "Settings"]
    }
    
    var iconName: String? {
        switch self {
        case .allRecords:
            return "focus_record_24"
        case .addRecord:
            return "focus_record_add_24"
        case .archived:
            return "archivedList_24"
        case .settings:
            return "gear_24"
        }
    }
}

class FocusMoreBarButtonItem: UIBarButtonItem {
    
    /// 选中菜单类型
    var didSelectType: ((FocusMoreMenuType) -> Void)?
    
    override init() {
        super.init()
        
        let button = FocusMoreButton()
        button.didSelectMenuAction = {[weak self] action in
            guard let type: FocusMoreMenuType = action.actionType() else {
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

private class FocusMoreButton: TPMenuListButton {
    
    override var menuItems: [TPMenuItem]? {
        get {
            let typeLists: [Array<FocusMoreMenuType>] = [
                [.allRecords,
                 .addRecord],
                [.archived,
                 .settings]
            ]
            
            let items = TPMenuItem.items(with: typeLists) { type, action in
                if type == .archived {
                    /// 归档计时器数目
                    let archivedTimersCount = Focus.numberOfArchivedTimers()
                    if archivedTimersCount > 0 {
                        action.valueText = "\(archivedTimersCount)"
                    }
                }
            }
            
            return items
        }
        
        set {}
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 5.0)
        self.image = resGetImage("ellipsis_circle_24")
        self.imageConfig.color = resGetColor(.title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
