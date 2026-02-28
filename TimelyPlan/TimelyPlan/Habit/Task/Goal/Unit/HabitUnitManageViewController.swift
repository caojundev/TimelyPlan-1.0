//
//  UnitViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2024/4/1.
//

import Foundation
import UIKit

class HabitUnitManageViewController: TPCollectionSectionsViewController {
    
    /// 选中单位回调
    var didSelectUnit: ((String) -> Void)?
    
    /// 用户区块
    let userSectionController = HabitUserUnitSectionController()
    
    /// 系统区块
    let systemSectionController = HabitSystemUnitSectionController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.collectionViewLayout = UICollectionViewLeftAlignedLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Units")
        self.preferredContentSize = CGSize(width: 280.0, height: 300.0)
        self.navigationItem.rightBarButtonItem = addBarButtonItem
        self.collectionView.showsVerticalScrollIndicator = false
        self.sectionControllers = [userSectionController,
                                   systemSectionController]
        
        self.adapter.sectionInset = UIEdgeInsets(horizontal: 8.0, vertical: 4.0)
        self.adapter.interitemSpacing = 8.0
        self.adapter.lineSpacing = 8.0
        self.adapter.cellStyle.cornerRadius = 8.0
        self.adapter.cellStyle.backgroundColor = .secondarySystemFill
        self.adapter.cellStyle.selectedBackgroundColor = .tertiarySystemFill
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .secondarySystemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .secondarySystemGroupedBackground
    }

    override func clickAdd() {
        TPImpactFeedback.impactWithSoftStyle()
        userSectionController.createNewUnit()
    }

}

/*
    func adapter(_ adapter: CollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        UIMenuController.shared.menuItems = nil
        UIMenuController.shared.hideMenu()
        dismiss(animated: true, completion: nil)
        
        if let unit = adapter.item(at: indexPath) as? String {
            didSelectUnit?(unit)
        }
    }
    
    // MARK: - Reorder
    func adapter(_ adapter: CollectionViewAdapter, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isUserSection(at: indexPath)
    }
    
    func adapter(_ adapter: CollectionViewAdapter, canMoveItemTo indexPath: IndexPath) -> Bool {
        return isUserSection(at: indexPath)
    }
    
    func adapterReorderDidBegan(_ adapter: CollectionViewAdapter) {
        TFImpactFeedback.impactWithSoftStyle()
        /// 隐藏菜单
        UIMenuController.shared.menuItems = nil
        UIMenuController.shared.hideMenu()
    }
    
    func adapterReorderDidEnded(_ adapter: CollectionViewAdapter) {
        let userSectionObject = UnitSection.user.rawValue as NSString
        guard let units = adapter.items(for: userSectionObject) as? [String] else {
            return
        }
        
        if userUnits != units {
            userUnits = units
            saveUserUnits()
        }
    }
    
    func adapter(_ adapter: CollectionViewAdapter, moveItemFrom fromIndexPath: IndexPath, to toIndexPath: IndexPath) -> Bool {
        TFImpactFeedback.impactWithSoftStyle()
        /// 这里不执行操作，在排序结束后再进行判断
        return true
    }
    

    // MARK: - 单位操作
    func createNewUnit(_ completion: ((String) -> Void)? = nil) {
        editUnit(nil, type: .create) { newUnit in
            if !self.userUnits.contains(newUnit) {
                self.userUnits.append(newUnit)
                self.saveUserUnits()
            }
            
            completion?(newUnit)
        }
    }
    
    func deleteUnit(at index: Int) {
        userUnits.remove(at: index)
        saveUserUnits()
        adapter.performUpdate()
    }
    
    func editUnit(at index: Int) {
        let unit = userUnits[index]
        editUnit(unit, type: .modify) { newUnit in
            if !self.userUnits.contains(newUnit) {
                self.userUnits.replaceElement(at: index, with: newUnit)
                self.saveUserUnits()
            }
        }
    }
}
*/
