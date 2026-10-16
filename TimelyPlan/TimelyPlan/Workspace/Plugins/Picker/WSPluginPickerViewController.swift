//
//  WSPluginPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/16.
//

import Foundation
import UIKit

/// 组件选择器。
///
/// 展示插件模块列表，选中后通过 `didSelectModule` 回调，并自动关闭。
class WSPluginPickerViewController: TPTableSectionsViewController {
    
    /// 选中模块回调
    var didSelectModule: ((WSPluginModule) -> Void)?
    
    /// 展示的模块列表，默认全部模块
    var modules: [WSPluginModule] = WSPluginModule.allCases
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Add Plugin")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.sectionControllers = makeSectionControllers()
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    private func makeSectionControllers() -> [TPTableBaseSectionController] {
        let sectionController = TPTableItemSectionController()
        sectionController.cellItems = modules.compactMap { module in
            makeCellItem(for: module)
        }
        
        return [sectionController]
    }
    
    /// 模块对应的单元格条目
    private func makeCellItem(for module: WSPluginModule) -> TPImageInfoTableCellItem? {
        let typesCount = module.types.count
        guard typesCount > 0 else {
            return nil
        }
        
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig.size = .default
        cellItem.imageConfig.shouldRenderImageWithColor = false
        cellItem.height = 64.0
        cellItem.title = module.displayName
        cellItem.imageName = module.iconName
        cellItem.valueConfig = .valueText("\(typesCount)")
        cellItem.didSelectHandler = { [weak self] in
            self?.pick(module)
        }
        
        return cellItem
    }
    
    // MARK: - 选择
    private func pick(_ module: WSPluginModule) {
        let vc = WSPluginGalleryViewController()
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(vc, animated: true)
    }
}
