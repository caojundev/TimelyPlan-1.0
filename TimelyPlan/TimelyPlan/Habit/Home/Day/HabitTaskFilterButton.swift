//
//  HabitTaskFilterButton.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/10.
//

import Foundation
import UIKit

class HabitTaskFilterButton: TPMenuListButton {
    
    var didSelectFilterType: ((HabitTaskFilterType) -> Void)?
    
    var filterType: HabitTaskFilterType = .all {
        didSet {
            if filterType != oldValue {
                updateInfo()
            }
        }
    }
    
    override var menuItems: [TPMenuItem]? {
        get {
            let typeLists: [Array<HabitTaskFilterType>] = [[.all],
                                                           [.todo],
                                                           [.completed, .skipped, .failed]]
            
            let selectedType = self.filterType
            let menuItems = TPMenuItem.items(with: typeLists, updater: { type, action in
                action.handleBeforeDismiss = true
                action.isChecked = selectedType == type
            })
            
            return menuItems
        }
        
        set {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 16.0)
        self.isCovered = true
        self.preferredPosition = .topRight
        self.cornerRadius = .greatestFiniteMagnitude
        self.normalBackgroundColor = .primary
        self.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        self.titleConfig.textColor = Color(0xffffff, 0.8)
        self.imageConfig.margins = .zero
        self.imageConfig.color = Color(0xffffff, 0.8)
        self.updateInfo()
        self.didSelectMenuAction = {[weak self] menuAction in
            let filterType: HabitTaskFilterType? = menuAction.actionType()
            if let filterType = filterType {
                self?.selectFilterType(filterType)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        return CGSize(width: max(size.width, 60.0), height: size.height)
    }
    
    private func selectFilterType(_ filterType: HabitTaskFilterType) {
        if self.filterType != filterType {
            self.filterType = filterType
            didSelectFilterType?(filterType)
        }
    }
    
    private func updateInfo() {
        self.image = resGetImage("chevron_upDown_16")
        self.title = filterType.title
        self.sizeToFit()
        self.superview?.setNeedsLayout()
    }
    
}
