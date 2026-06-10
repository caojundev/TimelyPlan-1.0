//
//  UnitViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/1.
//

import Foundation
import UIKit

class HabitUnitManageViewController: TPCollectionSectionsViewController,
                                        TPCollectionSectionControllerDelegate {
    
    /// 选中单位回调
    var didSelectUnit: ((String) -> Void)?
    
    /// 用户区块
    private let userSectionController = HabitUserUnitSectionController()
    
    /// 系统区块
    private let systemSectionController = HabitSystemUnitSectionController()
    
    /// 排序
    private var reorder: TPCollectionDragExchangeReorder?
    
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

        self.userSectionController.delegate = self
        self.systemSectionController.delegate = self
        self.sectionControllers = [userSectionController, systemSectionController]
        self.adapter.interitemSpacing = 8.0
        self.adapter.lineSpacing = 8.0
        self.adapter.cellStyle.cornerRadius = .greatestFiniteMagnitude
        self.adapter.cellStyle.backgroundColor = .secondarySystemFill
        self.adapter.cellStyle.selectedBackgroundColor = .tertiarySystemFill
        self.adapter.reloadData()
        self.setupReorder()
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

    private func setupReorder() {
        let reorder = TPCollectionDragExchangeReorder(collectionView: self.collectionView)
        reorder.delegate = userSectionController
        reorder.isEnabled = true
        self.reorder = reorder
    }
    
    // MARK: - TPCollectionSectionControllerDelegate
    func collectionSectionController(_ sectionController: TPCollectionBaseSectionController, didSelectItemAt index: Int) {
        
        let unit: String
        if sectionController.section == 0 {
            unit = userSectionController.unit(at: index)
        } else {
            unit = systemSectionController.unit(at: index)
        }
        
        didSelectUnit?(unit)
        dismiss(animated: true, completion: nil)
    }
}
