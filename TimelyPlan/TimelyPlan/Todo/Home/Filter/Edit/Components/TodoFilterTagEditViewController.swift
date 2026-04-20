//
//  TodoFilterTagEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/25.
//

import Foundation
import UIKit

class TodoFilterTagEditViewController: TPTableSectionsViewController,
                                        TPTableSectionControllerDelegate {
    
    var didEndEditing: ((TodoTagFilterValue?) -> Void)?
    
    private lazy var noTagSectionController: TodoFilterNoTagSectionController = {
        let sectionController = TodoFilterNoTagSectionController()
        sectionController.footerItem.height = 10.0
        sectionController.delegate = self
        sectionController.didSelectNoTag = { [weak self] in
            self?.selectNoTag()
        }
        
        return sectionController
    }()
    
    private lazy var userTagSectionController: TodoFilterUserTagSectionController = {
        let sectionController = TodoFilterUserTagSectionController()
        sectionController.delegate = self
        sectionController.didSelectTag = { [weak self] tag in
            self?.selectUserTag(tag)
        }
        
        return sectionController
    }()

    private var selectedTags: [TodoTag]
    
    private(set) var filterValue: TodoTagFilterValue
    
    init(filterValue: TodoTagFilterValue?) {
        self.filterValue = filterValue ?? TodoTagFilterValue()
        self.selectedTags = filterValue?.tags ?? []
        super.init(style: .insetGrouped)
        
        /// 更新选中标签标识
        if self.selectedTags.count != self.filterValue.identifiers?.count {
            self.updateTagIdentifiers()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Tag")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
        actionsBar?.backgroundColor = .systemGroupedBackground
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        sectionControllers = [noTagSectionController,
                              userTagSectionController]
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        super.clickDone()
        if self.filterValue.isEmpty {
            self.didEndEditing?(nil)
        } else {
            self.didEndEditing?(self.filterValue)
        }
    }
    
    private func selectNoTag() {
        if let includeNoTag = filterValue.includeNoTag, includeNoTag {
            filterValue.includeNoTag = nil
        } else {
            filterValue.includeNoTag = true
        }
        
        adapter.updateCheckmarks()
    }
    
    private func selectUserTag(_ tag: TodoTag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.append(tag)
        }
        
        updateTagIdentifiers()
        adapter.updateCheckmarks()
    }
    
    func updateTagIdentifiers() {
        let identifiers = selectedTags.map { $0.identifier }
        if identifiers.count > 0 {
            filterValue.identifiers = identifiers
        } else {
            filterValue.identifiers = nil
        }
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        if sectionController == userTagSectionController {
            if let tag = userTagSectionController.item(at: index) as? TodoTag {
                return self.selectedTags.contains(tag)
            }
        } else if sectionController == noTagSectionController{
            if let includeNoTag = self.filterValue.includeNoTag, includeNoTag {
                return true
            }
        }

        return false
    }
}

private class TodoFilterUserTagSectionController: TPTableBaseSectionController {
    
    var didSelectTag: ((TodoTag) -> Void)?
    
    override var items: [ListDiffable]? {
        return todo.getTags()
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 0.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 0.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 50.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TodoFilterTagSelectCell.self
    }
    
    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        super.didDequeCell(cell, forRowAt: index)
        guard let cell = cell as? TodoFilterTagSelectCell else {
            return
        }
        
        cell.userTag = item(at: index) as? TodoTag
    }
    
    override func didSelectRow(at index: Int) {
        super.didSelectRow(at: index)
        TPImpactFeedback.impactWithSoftStyle()
        guard let tag = item(at: index) as? TodoTag else {
            return
        }
        
        didSelectTag?(tag)
    }
}

class TodoFilterTagSelectCell: TPColorInfoTextValueTableCell {
    
    let colorSize = CGSize(width: 10.0, height: 10.0)
    let colorMargins = UIEdgeInsets(left: 0.0, right: 10.0)
    
    var userTag: TodoTag? {
        didSet {
            infoView.title = userTag?.name ?? resGetString("Untitled")
            let config = TPColorAccessoryConfig()
            config.color = userTag?.color ?? TodoTag.defaultColor
            config.size = colorSize
            config.margins = colorMargins
            self.colorConfig = config
        }
    }
    
    lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.padding = UIEdgeInsets(left: 16.0, right: 16.0)
        self.rightView = checkmarkView
        self.rightViewSize = .mini
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkView.updateImage(withColor: tintColor)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkView.isHidden = !checked
    }
}

class TodoFilterNoTagSectionController: TPTableItemSectionController {
    
    var didSelectNoTag: (() -> Void)? {
        didSet {
            noTagCellItem.didSelectHandler = didSelectNoTag
        }
    }
    
    lazy var noTagCellItem: TPCheckmarkTableCellItem = {
        let cellItem = TPCheckmarkTableCellItem()
        cellItem.height = 50.0
        cellItem.contentPadding = UIEdgeInsets(left: 8.0, right: 16.0)
        cellItem.imageConfig.margins = UIEdgeInsets(left: 0.0, right: 4.0)
        cellItem.imageConfig.size = .mini
        cellItem.imageConfig.color = .gray(5)
        cellItem.imageContent = .withName("todo_filter_tag_none_24")
        cellItem.title = resGetString("No Tag")
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [noTagCellItem]
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let bShow = delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index)
        return bShow ?? false
    }
}
