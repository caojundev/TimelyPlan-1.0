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
/// 展示插件模块列表，进入模块后通过画廊选中插件，点击「添加插件」或选中组件时通过 `didAddPlugin` 回调。
class WSPluginPickerViewController: TPTableSectionsViewController {
    
    /// 添加插件回调，参数为画廊中选中的插件
    var didAddPlugin: ((WSPlugin) -> Void)?
    
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
        let vc = WSPluginGalleryViewController(module: module)
        /// 画廊中选中插件后回传给外部添加
        vc.didClickAdd = { [weak self] plugin in
            self?.didAddPlugin?(plugin)
        }
        
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(vc, animated: true)
    }
}
