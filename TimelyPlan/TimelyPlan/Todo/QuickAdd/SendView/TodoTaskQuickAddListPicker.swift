//
//  TodoTaskQuickAddListButton.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/12.
//

import Foundation
import UIKit

class TodoTaskQuickAddListPicker: TPBaseButton {

    var didSelectList: ((TodoListRepresentable?) -> Void)?
    
    var list: TodoListRepresentable? {
        didSet {
            updateListInfo()
        }
    }
    
    let titleColor = Color(light: 0x646566, dark: 0xabacad)
    
    lazy var infoView: TPIconTitleView = {
        let view = TPIconTitleView()
        view.iconConfig.margins = .zero
        view.iconConfig.backColor = .clear
        view.iconConfig.placeholderImage = resGetImage("todo_list_24")
        view.titleConfig.textColor = titleColor
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 13.0)
        view.titleConfig.lineBreakMode = .byTruncatingMiddle
        return view
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.padding = .zero
        self.normalBackgroundColor = .clear
        self.selectedBackgroundColor = .clear
        self.contentView.addSubview(infoView)
        self.updateListInfo()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = layoutFrame()
    }
    
    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return infoView.sizeThatFits(size)
    }
    
    private func updateListInfo() {
        if let list = list as? TodoList {
            infoView.icon = list.icon
            infoView.title = list.title
            infoView.foreColor = list.color
        } else {
            /// 收件箱
            infoView.icon = TPIcon(name: "todo_list_inbox_24")
            infoView.title = resGetString("Inbox")
            infoView.foreColor = titleColor
        }

        superview?.setNeedsLayout()
    }

    override func didTouchUpInside() {
        super.didTouchUpInside()
        let selectView = TodoListSelectPopoverView()
        selectView.selectedList = self.list
        selectView.didSelectList = {[weak self] list in
            self?.selectList(list)
        }
        
        let sourceRect = self.bounds.insetBy(dx: -5.0, dy: -10.0)
        selectView.show(from: self,
                         sourceRect: sourceRect,
                         isCovered: false,
                         preferredPosition: .topRight,
                        permittedPositions: TPPopoverPosition.topPopoverPositions,
                         animated: true)
    }
    
    func selectList(_ list: TodoListRepresentable?) {
        let isEqual = self.list?.isEqual(list) ?? false
        if isEqual {
            return
        }
        
        self.list = list == nil ? TodoSmartList.inbox : list
        self.didSelectList?(list)
        superview?.setNeedsLayout()
    }
    
}
