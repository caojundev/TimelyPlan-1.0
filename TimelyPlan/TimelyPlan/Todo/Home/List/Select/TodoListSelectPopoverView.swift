//
//  TodoListSelectPopoverView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/10.
//

import Foundation

class TodoListSelectPopoverView: TPBasePopoverView {
    
    /// 选中列表回调
    var didSelectList: ((TodoListRepresentable?) -> Void)?

    /// 选中列表
    var selectedList: TodoListRepresentable? {
        didSet {
            selectView.list = selectedList
        }
    }
    
    var handleBeforeDismiss: Bool = true
    
    private let contentWidth = 260.0
    
    private let minimumContentHeight = 100.0
    
    private let maximumContentHeight = 300.0
    
    private var selectView: TodoListSelectView!
    
    override func setupSubviews() {
        super.setupSubviews()
        selectView = TodoListSelectView()
        selectView.didSelectList = { [weak self] list in
            self?.selectList(list)
        }
        
        self.popoverView = selectView
    }

    override var popoverContentSize: CGSize {
        var contentHeight = selectView.contentSize.height
        clampValue(&contentHeight, minimumContentHeight, maximumContentHeight)
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    func reloadData() {
        selectView.reloadData()
    }
    
    // MARK: - 选中菜单项
    private func selectList(_ list: TodoListRepresentable?) {
        if handleBeforeDismiss {
            self.didSelectList?(list)
            hide(animated: isHideWithAnimation)
        } else {
            hide(animated: isHideWithAnimation) {
                self.didSelectList?(list)
            }
        }
    }
}
