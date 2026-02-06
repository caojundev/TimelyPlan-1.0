//
//  TodoSortMenuListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/26.
//

import Foundation

class TodoSortMenuViewController: TPMenuListViewController {
  
    var allowSortTypes: [TodoSortType]?
    
    var allowSortOrders: [TodoSortOrder]?
    
    var didChangeSort: ((TodoSort) -> Void)?
    
    let sort: TodoSort
    
    init(sort: TodoSort) {
        self.sort = sort
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var menuItems = [TPMenuItem]()
        if let allowSortTypes = allowSortTypes, allowSortTypes.count > 1 {
            let menuItem = TPMenuItem.item(with: allowSortTypes) { [weak self] type, action in
                action.isChecked = type == self?.sort.type
                action.handler = { [weak self] _ in
                    self?.selectSortType(type)
                }
            }
            
            menuItems.append(menuItem)
        }
        
        if let allowSortOrders = allowSortOrders, allowSortOrders.count > 1 {
            let menuItem = TPMenuItem.item(with: allowSortOrders) { [weak self]  order, action in
                action.isChecked = order == self?.sort.order
                action.handler = { [weak self] _ in
                    self?.selectSortOrder(order)
                }
            }
            
            menuItems.append(menuItem)
        }
        
        self.menuItems = menuItems
        self.listView.reloadData()
    }

    private func selectSortType(_ type: TodoSortType) {
        guard self.sort.type != type else {
            return
        }
        
        var newSort = self.sort
        newSort.type = type
        self.didChangeSort?(newSort)
    }
    
    private func selectSortOrder(_ order: TodoSortOrder) {
        guard self.sort.order != order else {
            return
        }
        
        var newSort = self.sort
        newSort.order = order
        self.didChangeSort?(newSort)
    }
    
    /// 显示菜单列表
    func show(from sourceView: UIView, sourceRect: CGRect? = nil, isCovered: Bool = true) {
        let permittedPositions: [TPPopoverPosition] = [.bottomLeft,
                                                       .bottomRight,
                                                       .topLeft,
                                                       .topRight]
        self.popoverShow(from: sourceView,
                         sourceRect: sourceRect,
                         isSourceViewCovered: isCovered,
                         preferredPosition: .bottomLeft,
                         permittedPositions: permittedPositions,
                         animated: true,
                         completion: nil)
    }
    
}
