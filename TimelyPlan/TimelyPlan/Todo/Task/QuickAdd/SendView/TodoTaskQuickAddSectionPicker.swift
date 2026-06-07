//
//  TodoTaskQuickAddSectionPicker.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/12.
//

import Foundation
import UIKit

class TodoTaskQuickAddSectionPicker: TPBaseButton {

    var didSelectSection: ((TodoSectionFeature) -> Void)?
    
    var section: TodoSectionFeature = .none(for: nil) {
        didSet {
            updateSectionInfo()
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
        self.updateSectionInfo()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = layoutFrame()
    }
    
    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return infoView.sizeThatFits(size)
    }
    
    private func updateSectionInfo() {
        if let list = section.list {
            infoView.icon = list.icon
            infoView.foreColor = list.color
            infoView.title = list.name
        } else {
            /// 收件箱
            infoView.icon = TPIcon(name: "todo_list_inbox_24")
            infoView.foreColor = titleColor
        }

        infoView.title = section.title
        superview?.setNeedsLayout()
    }

    override func didTouchUpInside() {
        super.didTouchUpInside()
        let selectView = TodoTaskSectionSelectPopoverView(selectedSection: section)
        selectView.didSelectSection = { [weak self] section in
            self?.selectSection(section)
        }
        
        let sourceRect = self.bounds.insetBy(dx: -5.0, dy: -10.0)
        selectView.show(from: self,
                        sourceRect: sourceRect,
                        isCovered: false,
                        preferredPosition: .topRight,
                        permittedPositions: TPPopoverPosition.topPopoverPositions,
                        animated: true)
    }
    
    func selectSection(_ section: TodoSectionFeature) {
        guard self.section != section else {
            return
        }
        
        self.section = section
        didSelectSection?(section)
        superview?.setNeedsLayout()
    }
}
