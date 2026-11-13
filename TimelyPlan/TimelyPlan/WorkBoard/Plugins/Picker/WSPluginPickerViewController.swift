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
/// 按模块组划分 section，组内以网格展示模块：单组件模块直接添加，
/// 其余模块进入画廊选中插件，均通过 `didAddPlugin` 回调。
class WSPluginPickerViewController: TPCollectionSectionsViewController {
    
    /// 添加插件回调，参数为画廊中选中的插件或直接添加的插件
    var didAddPlugin: ((WSPlugin) -> Void)?
    
    /// 展示的模块组列表，默认全部模块组
    var groups: [WSPluginModuleGroup] = WSPluginModuleGroup.allCases
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.collectionViewLayout = UICollectionViewLeftAlignedLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Add Plugin")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.collectionView.showsVerticalScrollIndicator = false
        /// 网格样式由单元格内容自行绘制，去掉列表默认背景
        self.adapter.cellStyle.backgroundColor = .clear
        self.adapter.cellStyle.selectedBackgroundColor = .clear
        self.sectionControllers = makeSectionControllers()
        self.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    private func makeSectionControllers() -> [TPCollectionBaseSectionController] {
        return groups.compactMap { group -> TPCollectionBaseSectionController? in
            let sectionController = WSPluginModuleSectionController(group: group)
            guard let cellItems = sectionController.cellItems, cellItems.count > 0 else {
                return nil
            }
            
            sectionController.didSelectModule = { [weak self] module in
                self?.select(module)
            }
            
            return sectionController
        }
    }
    
    // MARK: - 选择
    /// 处理选中的模块：单组件模块直接添加，其余进入画廊
    private func select(_ module: WSPluginModule) {
        switch module.pickerStyle {
        case .gallery:
            pick(module)
        case .directAdd:
            addDirectly(module)
        }
    }
    
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
    private func addDirectly(_ module: WSPluginModule) {
        guard let type = module.directAddType else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        didAddPlugin?(WSPlugin(identifier: type.rawValue, type: type))
    }
}
