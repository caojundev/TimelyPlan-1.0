//
//  FocusQuickStartTypeView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/5.
//

import Foundation
import UIKit

class FocusQuickStartTypeView: UIView {
    
    var didSelectEditType: ((FocusQuickStartEditType) -> Void)?
    
    var selectedEditType: FocusQuickStartEditType {
        get {
            guard let tag = menuView.selectedMenuTag else {
                return .pomodoro
            }
            
            return FocusQuickStartEditType(rawValue: tag) ?? .pomodoro
        }
        
        set {
            menuView.selectMenu(withTag: newValue.rawValue)
        }
    }
    
    private let menuItemWidth = 80.0
       
    private lazy var menuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.normalBackgroundColor = .clear
        view.buttonNormalBackgroundColor = .clear
        view.buttonHighlightedBackgroundColor = .clear
        view.minButtonWidth = menuItemWidth
        view.maxButtonWidth = menuItemWidth
        view.padding = .zero
        view.imageConfig.size = .size(8)
        view.cornerRadius = 12.0
        view.didSelectMenuItem = { [weak self] menuItem in
            guard let editType: FocusQuickStartEditType = menuItem.actionType() else {
                return
            }
            
            self?.didSelectEditType?(editType)
        }
        
        view.menuItems = FocusQuickStartEditType.segmentedMenuItems(style: .icon)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSeparator(position: .top, color: .systemGray5)
        self.padding = UIEdgeInsets(value: 6.0)
        addSubview(menuView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        let itemsCount = CGFloat(menuView.menuItems.count)
        menuView.margin = (layoutFrame.width - menuItemWidth * itemsCount) / (itemsCount - 1)
        menuView.frame = layoutFrame
    }
    
}
