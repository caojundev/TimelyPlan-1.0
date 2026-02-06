//
//  TodoFolderSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation

class TodoFolderSelectViewController: TPTableSectionsViewController,
                                      TPTableSectionControllerDelegate,
                                      TodoFolderProcessorDelegate {
    
    /// 选中目录回调
    var didSelectFolder: ((TodoFolder?) -> Void)?

    /// 目录
    private(set) var folder: TodoFolder?
    
    /// 添加按钮
    lazy var addFolderButtonItem: UIBarButtonItem = {
        let image = resGetImage("todo_folder_add_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .done,
                                         target: self,
                                         action: #selector(clickAddFolder))
        return buttonItem
    }()
    
    /// 目录管理器
    private lazy var folderController: TodoFolderController = {
        let controller = TodoFolderController()
        return controller
    }()
    
    /// 无目录区块控制器
    private lazy var noneSectionController: TodoFolderSelectNoneSectionController = {
        let sectionController = TodoFolderSelectNoneSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    /// 用户目录区块控制器
    private lazy var userSectionController: TodoFolderSelectUserSectionController = {
        let sectionController = TodoFolderSelectUserSectionController()
        sectionController.delegate = self
        return sectionController
    }()
    
    init(folder: TodoFolder?) {
        self.folder = folder
        super.init(style: .insetGrouped)
        self.sectionControllers = [noneSectionController,
                                   userSectionController]
        todo.addUpdater(self, for: .folder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Select Folder")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        navigationItem.rightBarButtonItem = addFolderButtonItem
        setupActionsBar(actions: [doneAction])
        adapter.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    @objc private func clickAddFolder() {
        folderController.createNewFolder()
    }
    
    override func clickDone() {
        dismiss(animated: true, completion: nil)
        didSelectFolder?(folder)
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        var folder: TodoFolder? = nil
        if sectionController == userSectionController {
            folder = userSectionController.item(at: index) as? TodoFolder
        }

        self.folder = folder
        adapter.updateCheckmarks()
    }

    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        if sectionController == noneSectionController {
            return self.folder == nil
        }
        
        let folder = userSectionController.item(at: index) as? TodoFolder
        return self.folder == folder
    }
    
    // MARK: - TodoFolderProcessorDelegate
    /// 添加新组时通知
    func didCreateTodoFolder(_ folder: TodoFolder) {
        let sectionObject = userSectionController
        adapter.performSectionUpdate(forSectionObject: sectionObject) { _ in
            self.adapter.scrollToItem(folder, inSection: sectionObject) { _ in
                self.adapter.commitFocusAnimation(for: folder)
            }
        }
    }
    
    /// 更新目录信息通知
    func didUpdateTodoFolder(_ folder: TodoFolder) {
        adapter.reloadCell(forItems: [folder],
                           inSection: userSectionController,
                           rowAnimation: .automatic,
                           animateFocus: true)
    }
    
    /// 删除目录时通知
    func didDeleteTodoFolder(_ folder: TodoFolder) {
        adapter.performSectionUpdate(forSectionObject: userSectionController)
    }
}


class TodoFolderSelectNoneSectionController: TPTableItemSectionController {
    
    /// 无目录单元格条目
    lazy var noFolderCellItem:  TPCircularCheckboxInfoTableCellItem = {
        let cellItem = TPCircularCheckboxInfoTableCellItem()
        cellItem.title = resGetString("No Folder")
        cellItem.height = 50.0
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = 5.0
        self.cellItems = [noFolderCellItem]
    }
    
    override func shouldShowCheckmarkForRow(at index: Int) -> Bool {
        let shouldShow = delegate?.tableSectionController(self, shouldShowCheckmarkForRowAt: index)
        return shouldShow ?? false
    }
}

class TodoFolderSelectUserSectionController: TPTableBaseSectionController {
    
    /// 分区所有条目
    override var items: [ListDiffable]? {
        return todo.folders()
    }
    
    // MARK: - Delegate
    override func heightForHeader() -> CGFloat {
        return 10.0
    }
    
    override func heightForFooter() -> CGFloat {
        return 10.0
    }
    
    override func heightForRow(at index: Int) -> CGFloat {
        return 50.0
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return TPCircularCheckboxInfoTableCell.self
    }

    override func didDequeCell(_ cell: UITableViewCell, forRowAt index: Int) {
        guard let cell = cell as? TPCircularCheckboxInfoTableCell,
                let folder = item(at: index) as? TodoFolder else {
            return
        }
        
        cell.style = styleForRow(at: index)
        cell.title = folder.name ?? resGetString("Untitled Folder")
    }
}
