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
/// 按模块组划分 section，组内逐行展示模块；进入模块后通过画廊选中插件，
/// 点击「添加插件」或选中组件时通过 `didAddPlugin` 回调。
class WSPluginPickerViewController: TPTableSectionsViewController {
    
    enum Constants {
        
        /// 模块行高
        static let moduleRowHeight = 64.0
        
        /// 组标题高度
        static let groupHeaderHeight = 34.0
        
        /// 组标题内边距
        static let groupHeaderPadding = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 0.0, right: 10.0)
        
        /// 单模块组的区块间距。组内只有一个模块时，该行本身即是组入口，无需组标题
        static let sectionSpacing = 10.0
    }
    
    /// 添加插件回调，参数为画廊中选中的插件
    var didAddPlugin: ((WSPlugin) -> Void)?
    
    /// 展示的模块组列表，默认全部模块组
    var groups: [WSPluginModuleGroup] = WSPluginModuleGroup.allCases
    
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
        return groups.compactMap { group in
            makeSectionController(for: group)
        }
    }
    
    /// 一个模块组对应一个 section，组内按模块逐行展示；声明了预设变体的模块展开成多行
    private func makeSectionController(for group: WSPluginModuleGroup) -> TPTableItemSectionController? {
        let modules = group.availableModules
        guard modules.count > 0 else {
            return nil
        }
        
        let cellItems = modules.flatMap { makeCellItems(for: $0) }
        guard cellItems.count > 0 else {
            return nil
        }
        
        let sectionController = TPTableItemSectionController()
        sectionController.cellItems = cellItems
        sectionController.footerItem.height = 0.0
        
        /// 组内有多行时展示组标题，用于归纳同一业务拆分出的模块或同一模块的多种预设
        if cellItems.count > 1 {
            sectionController.headerItem.title = group.displayName
            sectionController.headerItem.height = Constants.groupHeaderHeight
            sectionController.headerItem.padding = Constants.groupHeaderPadding
            sectionController.headerItem.titleConfig.font = .boldSystemFont(ofSize: 13.0)
            sectionController.headerItem.titleConfig.textColor = resGetColor(.title)
        } else {
            sectionController.headerItem.height = Constants.sectionSpacing
        }
        
        return sectionController
    }
    
    /// 模块对应的单元格条目。有预设变体时按变体展开成多行
    private func makeCellItems(for module: WSPluginModule) -> [TPBaseTableCellItem] {
        let variants = module.pickerVariants
        guard variants.isEmpty else {
            return variants.compactMap { makeVariantCellItem(for: module, variant: $0) }
        }
        
        return [makeCellItem(for: module)].compactMap { $0 }
    }
    
    /// 模块对应的单元格条目
    private func makeCellItem(for module: WSPluginModule) -> TPBaseTableCellItem? {
        switch module.pickerStyle {
        case .gallery:
            return makeGalleryCellItem(for: module)
        case .directAdd:
            return makeDirectAddCellItem(for: module)
        }
    }
    
    /// 进入画廊的模块行
    private func makeGalleryCellItem(for module: WSPluginModule) -> TPBaseTableCellItem? {
        let typesCount = module.types.count
        guard typesCount > 0 else {
            return nil
        }
        
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig.size = .default
        cellItem.imageConfig.shouldRenderImageWithColor = false
        cellItem.height = Constants.moduleRowHeight
        cellItem.title = module.displayName
        cellItem.imageName = module.iconName
        cellItem.valueConfig = .valueText("\(typesCount)")
        cellItem.didSelectHandler = { [weak self] in
            self?.pick(module)
        }
        
        return cellItem
    }
    
    /// 直接添加整个模块的行
    private func makeDirectAddCellItem(for module: WSPluginModule) -> TPBaseTableCellItem? {
        guard let type = module.directAddType else {
            return nil
        }
        
        return makeDirectAddCellItem(title: module.displayName,
                                     iconName: module.iconName) { [weak self] in
            self?.addDirectly(type: type, configJSON: nil)
        }
    }
    
    /// 直接添加某个预设变体的行
    private func makeVariantCellItem(for module: WSPluginModule,
                                     variant: WSPluginModuleVariant) -> TPBaseTableCellItem? {
        guard let type = module.directAddType else {
            return nil
        }
        
        return makeDirectAddCellItem(title: variant.title,
                                     iconName: variant.iconName ?? module.iconName) { [weak self] in
            self?.addDirectly(type: type, configJSON: variant.configJSON)
        }
    }
    
    /// 直接添加行：右侧展示加号，点击整行或加号都执行添加
    private func makeDirectAddCellItem(title: String,
                                       iconName: String?,
                                       onAdd: @escaping () -> Void) -> TPBaseTableCellItem {
        let cellItem = TPImageInfoRightButtonTableCellItem()
        cellItem.imageConfig.size = .default
        cellItem.imageConfig.shouldRenderImageWithColor = false
        cellItem.height = Constants.moduleRowHeight
        cellItem.title = title
        cellItem.imageName = iconName
        cellItem.rightViewMargins = UIEdgeInsets(right: 8.0)
        cellItem.rightButtonImageName = "plus_24"
        cellItem.rightButtonNormalImageColor = .secondaryLabel
        cellItem.didSelectHandler = onAdd
        cellItem.didClickRightButton = { _ in onAdd() }
        
        return cellItem
    }
    
    // MARK: - 选择
    /// 进入画廊选择模块内的组件
    private func pick(_ module: WSPluginModule) {
        let vc = WSPluginGalleryViewController(module: module)
        /// 画廊中选中插件后回传给外部添加
        vc.didClickAdd = { [weak self] plugin in
            self?.didAddPlugin?(plugin)
        }
        
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 直接添加组件。关闭界面与插入位置由外部处理
    /// - Parameter configJSON: 预设的组件配置。为 nil 时组件使用默认配置
    private func addDirectly(type: WSPluginType, configJSON: String?) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let plugin = WSPlugin(identifier: type.rawValue, type: type)
        plugin.configJSON = configJSON
        didAddPlugin?(plugin)
    }
}
