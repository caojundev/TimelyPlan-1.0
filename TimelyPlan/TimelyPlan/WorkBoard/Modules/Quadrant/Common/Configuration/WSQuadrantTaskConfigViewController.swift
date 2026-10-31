//
//  WSQuadrantTaskConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 四象限任务组件的配置界面，用于选择要展示的象限
class WSQuadrantTaskConfigViewController: WSPluginConfigViewController {
    
    /// 当前配置
    private lazy var config: WSQuadrantTaskConfiguration = {
        return configuration(as: WSQuadrantTaskConfiguration.self) ?? WSQuadrantTaskConfiguration()
    }()
    
    /// 象限选择列表
    private lazy var selectionViewController: WSQuadrantSelectionViewController = {
        let viewController = WSQuadrantSelectionViewController(selectedQuadrant: config.targetQuadrant)
        viewController.didSelectQuadrant = { [weak self] quadrant in
            self?.selectQuadrant(quadrant)
        }
        
        return viewController
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Select Quadrant")
        contentViewController = selectionViewController
    }
    
    // MARK: - 选择
    /// 保存用户选择的象限
    private func selectQuadrant(_ quadrant: Quadrant) {
        var config = self.config
        config.quadrant = quadrant
        self.config = config
        updateConfiguration(config)
    }
}

// MARK: - 象限选择列表

/// 象限选择列表，按象限布局顺序展示，点击切换选中项
class WSQuadrantSelectionViewController: TPTableSectionsViewController,
                                        TPTableSectionControllerDelegate {
    
    /// 选择变化回调
    var didSelectQuadrant: ((Quadrant) -> Void)?
    
    /// 可选的象限，按布局顺序排列
    private let quadrants: [Quadrant]
    
    /// 当前选中的象限
    private var selectedQuadrant: Quadrant
    
    /// 列表数据
    private let sectionController = TPTableItemSectionController()
    
    init(selectedQuadrant: Quadrant) {
        self.quadrants = QuadrantSetting.shared.layout.getQuadrants()
        self.selectedQuadrant = selectedQuadrant
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.cellStyle.selectedBackgroundColor = .tertiarySystemFill
        
        sectionController.delegate = self
        sectionControllers = [sectionController]
        setupCellItems()
        reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - 数据
    /// 每个象限展示图标与名称
    private func setupCellItems() {
        sectionController.cellItems = quadrants.map { quadrant in
            let cellItem = TPCheckmarkTableCellItem()
            cellItem.title = quadrant.title
            cellItem.imageName = quadrant.iconName
            cellItem.imageColor = quadrant.color
            cellItem.imageConfig.shouldRenderImageWithColor = true
            return cellItem
        }
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                didSelectRowAt index: Int) {
        guard let quadrant = quadrants[safe: index], quadrant != selectedQuadrant else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        selectedQuadrant = quadrant
        adapter.updateCheckmarks()
        didSelectQuadrant?(quadrant)
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController,
                                shouldShowCheckmarkForRowAt index: Int) -> Bool {
        return quadrants[safe: index] == selectedQuadrant
    }
}
