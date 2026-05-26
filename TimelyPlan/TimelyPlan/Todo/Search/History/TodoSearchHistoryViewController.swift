//
//  TodoSearchHistoryViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/25.
//

import Foundation

class TodoSearchHistoryViewController: TPTableSectionsViewController,
                                       UISearchBarDelegate {
    
    var didSelectHistory: ((String) -> Void)?
    
    var insetBottom: CGFloat {
        return wrapperView.keyboardAdjusterInsetBottom
    }
    
    private lazy var histories: Set<TodoSearchHistory> = {
        return TodoState.shared.searchHistories ?? []
    }()
    
    private lazy var historySectionController: TPTableItemSectionController = {
        let controller = TPTableItemSectionController()
        controller.footerItem = clearHistoryFooterItem
        return controller
    }()
    
    private lazy var clearHistoryFooterItem: TodoSearchHistoryClearFooterItem = {
        let item = TodoSearchHistoryClearFooterItem()
        item.height = 40.0
        item.didClickClear = { [weak self] in
            self?.clickClear()
        }
        
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrapperView.isKeyboardAdjusterEnabled = true
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        setupSectionControllers()
        adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func insertHistory(_ history: TodoSearchHistory) {
        histories.insertOrUpdate(history)
        histories.keepLatest(maxCount: 6)
        saveHistories()
    }
    
    private func removeHistory(_ history: TodoSearchHistory) {
        histories.remove(history)
        saveHistories()
    }
    
    private func removeAllHistories() {
        histories.removeAll()
        saveHistories()
    }
    
    private func saveHistories() {
        TodoState.shared.searchHistories = histories
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text?.whitespacesAndNewlinesTrimmedString
        guard let text = text, text.count > 0 else {
            return
        }
        
        let history = TodoSearchHistory(keyword: text)
        insertHistory(history)
        setupSectionControllers()
        adapter.reloadData()
    }
    
    private func setupSectionControllers() {
        guard histories.count > 0 else {
            historySectionController.cellItems = nil
            sectionControllers = nil
            return
        }
        
        let cellItems = historyCellItems(with: histories)
        historySectionController.cellItems = cellItems
        sectionControllers = [historySectionController]
    }
    
    private func selectHistory(_ history: TodoSearchHistory) {
        didSelectHistory?(history.keyword)
        
        let newHistory = TodoSearchHistory(keyword: history.keyword)
        insertHistory(newHistory)
        setupSectionControllers()
        adapter.reloadData()
    }
    
    private func deleteHistory(_ history: TodoSearchHistory) {
        removeHistory(history)
        setupSectionControllers()
        adapter.performUpdate(with: .top, completion: nil)
    }
    
    private func clickClear() {
        removeAllHistories()
        setupSectionControllers()
        adapter.performUpdate(with: .top, completion: nil)
    }
    
    private func historyCellItems(with histories: Set<TodoSearchHistory>) -> [TPBaseTableCellItem] {
        let orderedHistorys = histories.sortedByTimestampLatestFirst()
        var cellItems = [TPBaseTableCellItem]()
        for history in orderedHistorys {
            let cellItem = TPImageInfoRightButtonTableCellItem()
            cellItem.identifier = history.keyword
            cellItem.title = history.keyword
            cellItem.imageName = "todo_search_history_24"
            cellItem.rightButtonImageName = "xmark_12"
            cellItem.didSelectHandler = { [weak self] in
                self?.selectHistory(history)
            }
            
            cellItem.didClickRightButton = { [weak self] _ in
                self?.deleteHistory(history)
            }
            
            cellItems.append(cellItem)
        }
        
        return cellItems
    }
    
}
