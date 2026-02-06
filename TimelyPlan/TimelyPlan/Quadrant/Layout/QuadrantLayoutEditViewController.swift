//
//  QuadrantLayoutEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/19.
//

import Foundation

class QuadrantLayoutEditViewController: TPTableSectionsViewController {
    
    var didEndEditing: ((QuadrantLayout) -> Void)?
    
    private(set) var layout: QuadrantLayout
    
    private lazy var editView: QuadrantLayoutEditView = {
        let quadrants = layout.getQuadrants()
        let titlePosition = layout.getTitlePosition()
        let view = QuadrantLayoutEditView(frame: view.bounds, quadrants: quadrants)
        view.titlePosition = titlePosition
        view.didChangeQuadrants = {[weak self] quadrants in
            self?.didChangeQuadrants(quadrants)
        }
        
        return view
    }()
    
    /// 标题位置
    private lazy var titlePositionCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.contentPadding = TableCellLayout.withoutAccessoryContentPadding
        cellItem.title = resGetString("Title Position")
        cellItem.updater = {
            self?.updateTitlePositionCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editTitlePosition()
        }
        
        return cellItem
    }()

    private lazy var titlePositionSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.cellItems = [titlePositionCellItem]
        return sectionController
    }()
    
    init(layout: QuadrantLayout) {
        self.layout = layout
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("View Layout")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        tableView.tableHeaderView = editView
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        setupActionsBar(actions: [doneAction])
        sectionControllers = [titlePositionSectionController]
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let editViewHeight = view.safeLayoutFrame().height - actionsBarHeight - 80.0
        editView.height = min(560.0, editViewHeight)
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func reloadData() {
        super.reloadData()
        editView.reloadData()
    }
    
    override func clickDone() {
        super.clickDone()
        didEndEditing?(layout)
    }
    
    // MARK: - 标题位置
    private func updateTitlePositionCellItem() {
        let titlePosition = layout.getTitlePosition()
        if titlePosition == .top {
            titlePositionCellItem.imageName = "quadrant_layout_titlePosition_top_24"
        } else {
            titlePositionCellItem.imageName = "quadrant_layout_titlePosition_bottom_24"
        }
        
        titlePositionCellItem.valueConfig = .valueText(titlePosition.title)
    }
    
    private func editTitlePosition() {
        let position: QuadrantTitlePosition
        if layout.getTitlePosition() == .top {
            position = .bottom
        } else {
            position = .top
        }
        
        /// 更新编辑视图
        editView.titlePosition = position
        editView.reloadData()
        
        layout.titlePosition = position
        adapter.reloadCell(forItem: titlePositionCellItem, with: .none)
    }
    
    private func didChangeQuadrants(_ quadrants: [Quadrant]) {
        layout.quadrants = quadrants
    }
}
