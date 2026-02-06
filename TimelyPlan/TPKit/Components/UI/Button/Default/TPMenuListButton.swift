//
//  TPMenuListButton.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/28.
//

import Foundation

class TPMenuListButton: TPDefaultButton {

    var didSelectMenuAction: ((TPMenuAction) -> Void)?
    
    var menuItems: [TPMenuItem]?
    
    var preferredPosition: TPPopoverPosition = .bottomLeft
    
    var permittedPositions: [TPPopoverPosition] = TPPopoverPosition.allCases
    
    var sourceRect: CGRect?
    
    var isCovered: Bool = true
    
    var menuContentWidth: CGFloat = 180.0
    
    override func didTouchUpInside() {
        super.didTouchUpInside()
        
        guard let menuItems = menuItems else {
            return
        }

        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = menuContentWidth
        menuList.menuItems = menuItems
        menuList.didSelectMenuAction = { action in
            self.didSelectMenuAction?(action)
        }
    
        let sourceRect = sourceRect ?? self.bounds
        menuList.popoverShow(from: self,
                             sourceRect: sourceRect,
                             isSourceViewCovered: isCovered,
                             preferredPosition: preferredPosition,
                             permittedPositions: permittedPositions,
                             animated: true,
                             completion: nil)
    }
        
}
